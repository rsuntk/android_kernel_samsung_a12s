Language: **English** | [Indonesian](README_ID.md)
## A. How to build
There's 2 method available here: CI (Github Action) and Manual build

### For CI:
1. Fork the repository
2. Go to Actions tab
3. Click 'I understand my workflows, go ahead and enable them'
4. Go to Build Kernel
5. Click 'Run workflow'
6. Set the variable
7. And click 'Run workflow' again
8. After kernel compilation/building success, see the file named "kernelfile" at artifact tab.

### For Manual build
1. Download it as a zip or run this command:
```sh
git clone https://github.com/rsuntk/android_kernel_samsung_a12s.git a12s_kernel && cd a12s_kernel
```

2. Open the terminal and type:
```sh
bash build.sh
```
## B. CI variable or options means
1. ```Kernel Revision:``` Set revision for kernel.
2. ```Kernel Strings:``` Set like kernel name for it. example: ```4.19.150-TragicHorizon```, the ```TragicHorizon``` is the kernel string.
3. ```Stock boot.img region:``` Select boot.img for Kernel (global: a127f, latam: a127m)
4. ```KernelSU branch:``` Select KernelSU branch (stable: release-tags, dev: main-branch)
5. ```KernelSU support:``` Add support for KernelSU?
6. ```SELinux Permissive:``` Is SELinux Permissive?
7. ```Upload Image.gz file:``` If you building a recovery and need a Kernel file, well, turn on this option.

## C. Credit
- [Physwizz](https://github.com/physwizz) - OEM and Permissive kernel source
- [Rissu](https://github.com/rsuntk) - Rebased, Upstreamed kernel source & GH-Actions kernel builder
- [KernelSU](https://kernelsu.org) - A kernel-based root solution for Android
