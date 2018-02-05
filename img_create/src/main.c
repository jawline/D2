#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#define TO_CLUSTER(x) (x - data_segment_start) / (sector_size * info->sectors_per_cluster)
#define GET_CLUSTER(x) (uint16_t*)(fat_1 + (cluster_entry_size * x))

const size_t fat_bpp_offset = 3;
const size_t sector_size = 512;
const size_t num_sectors_fat = 8;
const size_t num_sectors_root_dir = 16;
const size_t cluster_entry_size = 2;

typedef struct {
    uint8_t oem_identifier[8];
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t num_fats;
    uint16_t max_root_entries;
    uint16_t sector_count;
    uint8_t junk_1;
    uint16_t sectors_per_fat;
    uint16_t sectors_per_track;
    uint16_t num_heads;
    uint32_t hidden_sectors;
    uint32_t large_sector_count;
    uint8_t drive_number;
    uint8_t window_nt_flags;
    uint8_t boot_signature;
    uint32_t volume_id;
    char volume_label[11];
    char fs_type[8];
} __attribute__ ((packed)) fat_bpp;

typedef struct {
    char filename[8];
    char ext[3];
    uint8_t attributes;
    uint16_t junk_1;
    uint16_t c_time;
    uint16_t c_date;
    uint16_t la_date;
    uint16_t ignore_fat12;
    uint16_t lw_time;
    uint16_t lw_date;
    uint16_t first_cluster;
    uint32_t file_size;
} __attribute__ ((packed)) fat_file_entry;

uint8_t* read_bootloader(char const* bootloader_path) {
    
    FILE* f = fopen(bootloader_path, "rb");

    if (!f) {
        return 0;
    }

    //Allocate memory for the bootloader
    uint8_t* bootloader = malloc(512);
    memset(bootloader, 0, 512);

    size_t num_bytes_read = fread(bootloader, 1, 512, f);

    if (num_bytes_read == 0 || ferror(f)) {
        free(bootloader);
        return 0;
    }

    return bootloader;
}

uint8_t* load_file(char const* path, size_t* length) {

    FILE* f = fopen(path, "rb");

    if (!f) {
        return 0;
    }

    //Calculate length
    fseek(f, 0, SEEK_END);
    *length = ftell(f);
    fseek(f, 0, SEEK_SET);

    uint8_t* data = malloc(*length);
    
    if (fread(data, *length, 1, f) != 1) {
        free(data);
        return 0;
    } 

    return data;
}

uint8_t append(uint8_t* dst, size_t* dst_length, uint8_t* src, size_t src_length) {
    
    if (!realloc(dst, (*dst_length) + src_length)) {
        return 0;
    }

    memcpy(dst + (*dst_length), src, src_length);
    *dst_length += src_length;
    return 1;
}

uint8_t write_img(uint8_t const* img, size_t img_size, char const* out_path) {
    FILE* fout = fopen(out_path, "wb");

    if (!fout) {
        return 0;
    }

    return fwrite(img, img_size, 1, fout) == 1;
}

uint8_t* allocate_sectors(uint8_t* current_data, size_t* current_length, size_t num_sectors) {
    size_t fat_start = *current_length;

    *current_length += (sector_size * num_sectors);
    
    if (!realloc(current_data, *current_length)) {
        return 0;
    }

    memset(current_data + fat_start, 0, sector_size * num_sectors);

    return current_data + fat_start;
}

void write_to_directory(uint8_t* directory_offset, char const* filename, size_t start_sector, size_t end_sector) {
    fat_file_entry new_entry;
    memset(&new_entry, 0, sizeof(fat_file_entry));
}

uint8_t write_file(char const* filepath, uint8_t* current_data, size_t* current_length) {
    size_t file_length;
    uint8_t* file_loaded = load_file(filepath, &file_length);

    if (!file_loaded) {
        return 0;
    }

    //Round to the nearest sector
    size_t num_sectors = file_length / sector_size;
    if (file_length % sector_size != 0) {
        num_sectors += 1;
    }

    printf("File will consume %i sectors (%i/%i)\n", num_sectors, file_length, sector_size);

    uint8_t* data_segment = allocate_sectors(current_data, current_length, num_sectors);
    memcpy(data_segment, file_loaded, file_length);

    printf("Wrote %s\n", filepath);

    free(file_loaded);
}

void init_fs_info(fat_bpp* info) {
    memset(info, 0, sizeof(fat_bpp));

    strcpy(info->oem_identifier, "MSWIN4.1");
    strcpy(info->volume_label, "OSTEST");
    strcpy(info->fs_type, "FAT16");

    info->bytes_per_sector = sector_size;
    info->sectors_per_cluster = 1; //For now? 
    info->num_fats = 2; //For some reason having 2 fats is common
    info->max_root_entries = 512 / 32; //1 sector
    info->sectors_per_fat = num_sectors_fat;
    info->num_heads = 1;
    info->boot_signature = 0x28;
    info->volume_id = 1;
}

void finalize_fs_info(fat_bpp* info, uint8_t* final_data, size_t final_length) {

    /**
     * Finalize FS info
     */

    info->sector_count = final_length / sector_size;
    info->large_sector_count = info->sector_count;
    info->sectors_per_track = info->sector_count;
 
    memcpy(final_data + fat_bpp_offset, info, sizeof(fat_bpp));
    printf("Write fs_info %i into %i-%i\n", sizeof(fat_bpp), fat_bpp_offset, fat_bpp_offset + sizeof(fat_bpp));
}

void write_files(char** files, size_t num_files, fat_bpp* info, uint8_t* final_data, size_t* final_length, size_t data_segment_start, uint8_t* root_directory, size_t* root_dir_pointer, uint8_t* fat_1) {
    
    //Write the files in
    for (int i = 0; i < num_files; i++) {
        char* current = files[i];
        printf("Loading %s\n", current);
        
        size_t start = *final_length;
        write_file(current, final_data, final_length);      
        size_t end = *final_length;

        char* name = current;
        char* temp = strtok(name, "/");

        while (temp) {
            name = temp;
            temp = strtok(0, "/");
        }

        printf("Decided on %s\n", name);
    
        fat_file_entry new_file;
        memset(&new_file, 0, sizeof(fat_file_entry));

        printf("Created new FS entry\n");

        strcpy(new_file.filename, name);

        printf("Copied Name\n");

        new_file.file_size = end - start;
        new_file.first_cluster = TO_CLUSTER(start);
        size_t end_cluster = TO_CLUSTER(end);

        printf("Decided first cluster will be %i (real offset %i)\n", new_file.first_cluster, start - data_segment_start);
        printf("I will end at cluster %i (Real offset %i)\n", TO_CLUSTER(end), end - data_segment_start);

        for (unsigned int i = new_file.first_cluster; i < end_cluster; i++) {
            *GET_CLUSTER(i) = i + 1;
        }
        *GET_CLUSTER(end_cluster) = 0xFFFF;

        printf("Wrote the FAT\n");

        memcpy(root_directory + *root_dir_pointer, &new_file, sizeof(fat_file_entry));
        *root_dir_pointer += sizeof(fat_file_entry);
    }
}

int main(int argc, char** argv) {
    
    if (argc < 4) {
        printf("img_create needs a bootloader and a target at a minimum\n");
        return -1;
    }

    //Construct a new master record
    fat_bpp fs_info;
    init_fs_info(&fs_info);

    uint8_t* final_data = read_bootloader(argv[1]);
    size_t final_length = sector_size;

    if (!final_data) {
        printf("Failed to read the bootloader\n");
        return -1;
    }

    printf("Read bootloader %s\n", argv[1]);

    printf("Writing Stage2\n");
    
    if (!write_file(argv[2], final_data, &final_length)) {
        return -1;
    }

    //Save the number of reserved sectors
    fs_info.reserved_sectors = final_length / sector_size;

    //Allocate FAT tables
    uint8_t* fat_1 = allocate_sectors(final_data, &final_length, num_sectors_fat);
    uint8_t* fat_2 = allocate_sectors(final_data, &final_length, num_sectors_fat);

    memset(fat_1, 0xFF, num_sectors_fat * sector_size);
    memset(fat_2, 0xFF, num_sectors_fat * sector_size);

    //Allocate space for the root directory
    uint8_t* root_directory = allocate_sectors(final_data, &final_length, num_sectors_root_dir);
    size_t root_dir_pointer = 0;

    if (!fat_1 || !fat_2 || !root_directory) {
        printf("Failed to allocate memory for FAT tables and root directory\n");
        return -1;
    }

    size_t data_segment_start = final_length;    

    //Write im_create s1 s2 $...$ out to the file
    write_files(argv + 3, argc - 4, &fs_info, final_data, &final_length, data_segment_start, root_directory, &root_dir_pointer, fat_1);

    //Copy fat_1 into fat_2
    memcpy(fat_2, fat_1, sector_size * num_sectors_fat);

    //Finalize the first sector header
    finalize_fs_info(&fs_info, final_data, final_length);

    if (!write_img(final_data, final_length, argv[argc - 1])) {
        printf("Failed to write image\n");
        return -1;
    }

    printf("Wrote final image %s\n", argv[argc - 1]);
    return 0;
}
