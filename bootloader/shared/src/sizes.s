;---
;- General boot sector stuff
;---

%define sector_size 512

%define stage_1_start 0x7C00
%define stage_2_start 0x7E00

%define stage_1_size (1 * sector_size)
%define stage_2_size (8 * sector_size)

%define kernel_target_addr 0x100000

;---
;- Disk read details
;---

%define max_retries 10

;---
;- Pointer to FS info
;---

%define oem_identifier stage_1_start + 3
%define volume_name stage_1_start + 43
%define reserved_sectors stage_1_start + 14
%define sectors_per_fat stage_1_start + 22
%define total_fats stage_1_start + 16
%define root_dir_entries stage_1_start + 17
%define sectors_per_cluster stage_1_start + 13

%define directory_entry_cluster_offset 26
%define bytes_per_dir_entry 32
