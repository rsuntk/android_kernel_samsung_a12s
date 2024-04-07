Bahasa: [Bahasa Inggris](README.md) | **Bahasa Indonesia**
## A. Cara mem-build Kernel
Ada dua cara yang tersedia disini: CI (Github Action) dan build local/manual

### Untuk build dengan cara CI:
1. Fork repository ini
2. Pergi ke bagian 'Actions'
3. Klik 'I understand my workflows, go ahead and enable them'
4. Pergi ke bagian 'Build Kernel'
5. Lalu klik 'Run workflow'
6. Atur variabel nya
7. Dan klik 'Run workflow' lagi
8. Setelah selesai, maka file yang bernama "kernelfile" akan tersedia di 'Artifact'

### For Manual build
1. Unduh sebagai file zip atau jalankan perintah: 
```sh
git clone https://github.com/rsuntk/android_kernel_samsung_a12s.git a12s_kernel && cd a12s_kernel
```

2. Ubah ```local_config.cfg```
File local_config.cfg terlihat seperti ini:
```
# Local Configuration
# only use lowercase!

# Booleans
PERMISSIVE: true
KSU_STATE: false

# Strings
#
# Available ksu_branch: stable and dev
# Available boot_img_region: global and latam
#
REVISION: 3
KSU_BRANCH: stable
KERNEL_NAME: TragicHorizon
BOOT_REGION: global
```

3. Buka terminal dan jalankan perintah:
```sh
bash build.sh
```
## B. Arti dari variabel atau pilihan di CI
1. ```Kernel Revision:``` Atur revisi kernel.
2. ```Kernel Strings:``` Nama kernel. contoh: ```4.19.150-TragicHorizon```, ```TragicHorizon``` adalah nama kernelnya.
3. ```Stock boot.img region:``` Pilih boot.img untuk Kernelnya (global: a127f, latam: a127m)
4. ```KernelSU branch:``` Pilih branch dari KernelSU (stable: release-tags, dev: main-branch)
5. ```KernelSU support:``` Tambahkan dukungan untuk KernelSU?
6. ```SELinux Permissive:``` Apakah SELinux-nya Permissive?
7. ```Upload Image.gz file:``` Jika kamu membuat sebuah custom recovery, aktifkan opsi ini.

## C. Credit
- [Physwizz](https://github.com/physwizz) - OEM and Permissive kernel source
- [Rissu](https://github.com/rsuntk) - Rebased, Upstreamed kernel source & GH-Actions kernel builder
- [KernelSU](https://kernelsu.org) - A kernel-based root solution for Android
