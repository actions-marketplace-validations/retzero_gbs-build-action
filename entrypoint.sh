#!/bin/bash

set -x

DOCKER_IMAGE=retzero/tizen_gbs:latest
CONTAINER_NAME=builder_ct
DEFAULT_GBS_ROOT=/root/GBS-ROOT/local/repos

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
OUTPUT_DIR=${GITHUB_WORKSPACE}/.gbs_build_output
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

docker pull ${DOCKER_IMAGE}

docker run -id --privileged --name ${CONTAINER_NAME} --workdir ${GITHUB_WORKSPACE} ${DOCKER_IMAGE}

# FIXME: Try volume mounting in DinD instead of copy files.
docker cp ${GITHUB_WORKSPACE}/. ${CONTAINER_NAME}:${GITHUB_WORKSPACE}

build_options="$define_macro $build_conf $baselibs"
clean_options="$clean $clean_once $fail_fast"
dep_options="$full_build $deps_build"
docker exec -i ${CONTAINER_NAME} gbs -d -v $gbs_conf build $profile $architecture $build_options $clean_options $dep_options $threads

[ -d "_git" ] && mv _git .git

# Copy build artifacts back to host container
docker cp ${CONTAINER_NAME}:${DEFAULT_GBS_ROOT}/${PROFILE}/. ${OUTPUT_DIR}

docker stop ${CONTAINER_NAME}

docker rm ${CONTAINER_NAME}
