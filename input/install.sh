#!/bin/bash
set -e

# This file should run any installation your input stage requires
# You can replace its content. It must run in bash and take in no arguments

# ----------------------------------------------------------------
# Below is a default installation for an executable that watches a 
# directory and calls input-callback when this occurs

dir_this_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))/
loc_watcher="$dir_this_dir"/DirectoryCreatedWatcher

if [ -f "$loc_watcher" ]; then
    echo "Directory watcher already found at $loc_watcher"
else
    # Get and build the code from GitHub

    # -- Make a temp dir to download to, which will be automatically deleted when we exit
    dir_src=$(mktemp -d)
    trap 'echo cleaning up... && [[ -d "$dir_src" ]] && rm -rf "$dir_src"' EXIT INT TERM

    # -- Download
    git clone --depth 1 https://github.com/Radiology-Morrison-lab-UCSF/DirectoryCreatedWatcher.git "$dir_src"

    # -- Build
    cd "$dir_src"
    bash ./unix-build.sh

    # Copy the built executable to this folder
    cp DirectoryCreatedWatcher/bin/Release/net8.0/linux-x64/native/DirectoryCreatedWatcher "$loc_watcher"

    cd "$dir_this_dir"
fi

echo "Input Stage Install Complete"