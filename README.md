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

### For Manual build
1. Download it as a zip or 
```sh
git clone https://github.com/rsuntk/android_kernel_samsung_a12s.git a12s_kernel && cd a12s_kernel
```

2. Edit ```local_config.cfg```
The local_config.cfg file looks like this:
```
# Local Configuration
# only use lowercase!

# Booleans
PERMISSIVE: true
KSU_STATE: false

# Strings
#
# Available ksu_branch: stable and dev
#
REVISION: 3
KSU_BRANCH: stable
KERNEL_NAME: TragicHorizon
```

3. Open the terminal and type:
```sh
bash build.sh
```

## B. Credit
- [Physwizz](https://github.com/physwizz) - OEM and Permissive kernel source
- [Rissu](https://github.com/rsuntk) - Rebased, Upstreamed kernel source & GH-Actions kernel builder
- [KernelSU](https://kernelsu.org) - A kernel-based root solution for Android
