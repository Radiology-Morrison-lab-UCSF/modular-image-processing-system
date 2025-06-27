#!/bin/bash
set -e

# This file should run any installation your processing stage requires
# You can replace its content. It must run in bash and take in no arguments

echo "Processing Stage Install Beginning"

dir_this_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))/
loc_final_sif="$dir_this_dir/qsm-processing-pipeline.sif"

BuildApptainerContainer() {
    local dir_src=$(mktemp -d)
    trap 'echo cleaning up... && [[ -d "$dir_src" ]] && rm -rf "$dir_src"' EXIT INT TERM

    git clone --depth 1 https://github.com/Radiology-Morrison-lab-UCSF/qsm-processing "$dir_src"

    cd "$dir_src"
    ./build-as-apptainer.sh

    cp *.sif "$dir_this_dir/qsm-processing-pipeline.sif"
    cd "$dir_this_dir"
}


if [ -f "$loc_final_sif" ]; then
    echo "Install skipped as found $loc_final_sif"
else
    BuildApptainerContainer
fi

echo "Processing Stage Install Completed"