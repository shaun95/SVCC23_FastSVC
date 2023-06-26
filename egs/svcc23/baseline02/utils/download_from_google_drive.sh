#!/bin/bash

# Copyright 2020 Tomoki Hayashi
#  MIT License (https://opensource.org/licenses/MIT)

# Download zip, tar, or tar.gz file from google drive

# shellcheck disable=SC1091
. ./path.sh || eixit 1

share_url=$1
download_dir=${2:-"downloads"}
file_ext=${3:-"zip"}

if [ "$1" = "--help" ] || [ $# -lt 1 ] || [ $# -gt 3 ]; then
   echo "Usage: $0 <share-url> [<download_dir> <file_ext>]";
   echo "e.g.: $0 https://drive.google.com/open?id=xxxxxxxxxxxxxx downloads zip"
   echo "Options:"
   echo "    <download_dir>: directory to save downloaded file. (Default=downloads)"
   echo "    <file_ext>: file extension of the file to be downloaded. (Default=zip)"
   exit 1;
fi

set -euo pipefail

[ ! -e "${download_dir}" ] && mkdir -p "${download_dir}"
tmp=$(mktemp "${download_dir}/XXXXXXXX.${file_ext}")

file_id=$(echo "${share_url}" | cut -d"=" -f 2)

# define decompressor
decompress () {
    filename=$1
    decompress_dir=$2
    if echo "${filename}" | grep -q ".zip"; then
        unzip "${filename}" -d "${decompress_dir}"
    elif echo "${filename}" | grep -q -e ".tar" -e ".tar.gz" -e ".tgz"; then
        tar xvzf "${filename}" -C "${decompress_dir}"
    else
        echo "Unsupported file extension." >&2 && exit 1
    fi
}

set -e
# Solution from https://github.com/wkentaro/gdown
gdown --id "${file_id}" -O "${tmp}"
decompress "${tmp}" "${download_dir}"

# remove tmpfiles
rm "${tmp}"
echo "Sucessfully downloaded ${file_ext} file from ${share_url}"
