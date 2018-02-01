#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

const size_t fat_bpp_sector_offset = 11;
const size_t sector_size = 512;
const size_t num_sectors_fat = 8;

typedef struct {
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
    uint32_t junk_2;
    uint32_t total_sector_count_fat32;
    uint16_t junk_3;
    uint8_t boot_signature;
    uint32_t volume_id;
    char volume_label[11];
    char fs_type[8];
} __attribute__ ((packed)) fat_bpp;

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

uint8_t* allocate_fat_table(uint8_t* current_data, size_t* current_length) {
    size_t fat_start = *current_length;

    *current_length += (sector_size * num_sectors_fat);
    
    if (!realloc(current_data, *current_length)) {
        return 0;
    }

    return current_data + fat_start;
}

int main(int argc, char** argv) {
    
    if (argc < 3) {
        printf("img_create needs a bootloader and a target at a minimum\n");
        return -1;
    }

    uint8_t* final_data = read_bootloader(argv[1]);
    size_t final_length = 512;

    if (!final_data) {
        printf("Failed to read the bootloader\n");
    }

    printf("Read bootloader %s\n", argv[1]);

    //Allocate FAT tables
    uint8_t* fat_1 = allocate_fat_table(final_data, &final_length);
    uint8_t* fat_2 = allocate_fat_table(final_data, &final_length);

    if (!fat_1 || !fat_2) {
        printf("Failed to allocate memory for FAT tables\n");
        return -1;
    }

    //Write the files in
    for (int i = 2; i < argc - 1; i++) {
        printf("Loading %s\n", argv[i]);
        size_t last_file_length;
        uint8_t* file_loaded = load_file(argv[i], &last_file_length);

        if (!file_loaded) {
            printf("Failed to load %s\n", argv[i]);
            return -1;
        }

        if (!append(final_data, &final_length, file_loaded, last_file_length)) {
            printf("Failed to write into final data %s\n", argv[i]);
            return -1;
        }

        printf("Wrote %s\n", argv[i]);

        free(file_loaded);
    }

    if (!write_img(final_data, final_length, argv[argc - 1])) {
        printf("Failed to write image\n");
        return -1;
    }

    printf("Wrote final image %s\n", argv[argc - 1]);
    return 0;
}
