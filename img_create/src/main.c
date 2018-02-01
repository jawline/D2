#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

const size_t fat_bpp_sector_offset = 11;

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

uint8_t write_img(uint8_t const* img, size_t img_size, char const* out_path) {
    FILE* fout = fopen(out_path, "wb");

    if (!fout) {
        return 0;
    }

    return fwrite(img, img_size, 1, fout) == 1;
}

int main(int argc, char** argv) {
    
    if (argc < 3) {
        printf("img_create needs a bootloader and a target at a minimum\n");
        return -1;
    }

    uint8_t* bootloader = read_bootloader(argv[1]);

    if (!bootloader) {
        printf("Failed to read the bootloader\n");
    }

    printf("Read bootloader %s\n", argv[1]);

    if (!write_img(bootloader, 512, argv[argc - 1])) {
        printf("Failed to write image\n");
        return -1;
    }

    printf("Wrote final image %s\n", argv[argc - 1]);
    return 0;
}
