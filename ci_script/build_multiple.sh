#! /usr/bin/env bash

#
# Rissu Project (C) 2024
#

export GITSHA=$(git describe --tags --always)

bash $(pwd)/ci_script/build_ksu_stable_permissive.sh
rm -rR $(pwd)/out -f

bash $(pwd)/ci_script/build_ksu_stable_enforcing.sh
rm -rR $(pwd)/out -f

bash $(pwd)/ci_script/build_ksu_dev_permissive.sh
rm -rR $(pwd)/out -f

bash $(pwd)/ci_script/build_ksu_dev_enforcing.sh
rm -rR $(pwd)/out -f

bash $(pwd)/ci_script/build_kernel_permissive.sh
rm -rR $(pwd)/out -f

bash $(pwd)/ci_script/build_kernel_enforcing.sh
rm -rR $(pwd)/out -f
