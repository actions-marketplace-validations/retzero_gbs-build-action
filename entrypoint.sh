#!/bin/bash

set -x

## global options
gbs_conf=""; if [ ! -z $1 ]; then gbs_conf="-c $1"; fi
debug=""; if [ $2 = "true" ]; then debug="--debug"; fi
verbose=""; if [ $3 = "true" ]; then verbose="--verbose"; fi

## build configuration options
profile=""; if [ ! -z $4 ]; then profile="--profile $4"; fi
architecture=""; if [ ! -z $5 ]; then architecture="--arch $5"; fi
define_macro=""; if [ ! -z $6 ]; then define_macro="--define $6"; fi
build_conf=""; if [ ! -z $7 ]; then build_conf="--dist $7"; fi
baselibs=""; if [ $8 = "true" ]; then baselibs="--baselibs"; fi

## build env options
clean=""; if [ $9 = "true" ]; then clean="--clean"; fi
clean_once=""; if [ ${10} = "true" ]; then clean_once="--clean_once"; fi
fail_fast=""; if [ ${11} = "true" ]; then fail_fast="--fail-fast"; fi
vm_memory=""; if [ ${12} -ne 0 ]; then vm_memory="--vm-memory ${12}"; fi
vm_disk=""; if [ ${13} -ne 0 ]; then vm_disk="--vm-disk ${13}"; fi
vm_swap=""; if [ ${14} -ne 0 ]; then vm_swap="--vm-swap ${14}"; fi
vm_diskfilesystem=""; if [ ${15} -ne 0 ]; then vm_diskfilesystem="--vm-diskfilesystem ${15}"; fi
full_build=""; if [ ${16} = "true" ]; then full_build="--full-build"; fi
deps_build=""; if [ ${17} = "true" ]; then deps_build="--deps-build"; fi
threads=""; if [ ${18} -ne 0 ]; then threads="--threads ${18}"; fi

## output
OUTPUT_DIR=
if [ ! -z ${19} ]; then OUTPUT_DIR="${19}"; fi

## Package directory list
if [ ! -z "${20}" ]; then
  [ -d ".git" ] && mv .git _git
  git config --global user.email "test@test.com"
  git config --global user.name "test"
  for package_name in ${20}; do
    pushd $package_name
    if [ ! -d ".git" ]; then
      git init .
      git checkout -b tizen
      git add .
      git commit -m "Including sources"
    fi
    popd
  done
fi

build_options="$define_macro $build_conf $baselibs"
clean_options="$clean $clean_once $fail_fast"
dep_options="$full_build $deps_build"

DEFAULT_GBS_ROOT=/usr/workspace/GBS-ROOT

gbs -d -v $gbs_conf build ${GITHUB_WORKSPACE} -B ${DEFAULT_GBS_ROOT} $profile $architecture $build_options $clean_options $dep_options $threads

if [ $? -ne 0 ]; then
  exit 1
fi

[ -d "_git" ] && mv _git .git

if [ ! -z ${OUTPUT_DIR} ]; then
  ugid=$(stat -c "%u:%g" ${GITHUB_WORKSPACE})
  chown -R ${ugid} ${DEFAULT_GBS_ROOT}/local/repos/
  cp -rf ${DEFAULT_GBS_ROOT}/local/repos/${PROFILE}/* ${OUTPUT_DIR}/
fi
