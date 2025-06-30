#!/bin/bash
set -e

dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

source "$dir_this_module/paths.sh"

BuildApptainerContainer() {
    local dir_src=$(mktemp -d)
    trap 'echo cleaning up... && [[ -d "$dir_src" ]] && rm -rf "$dir_src"' EXIT INT TERM

    git clone --depth 1 https://github.com/Radiology-Morrison-lab-UCSF/qsm-processing "$dir_src"

    cd "$dir_src"
    ./build-as-apptainer.sh

    cp *.sif "$loc_qsm_apptainer_image"
    cd "$dir_this_module"
}

InstallDcm2niix() {
    if [ -e "$loc_dcm2niix" ]; then
        echo "$loc_dcm2niix found"
        return
    fi

    local url_dcm2niix="https://github.com/rordenlab/dcm2niix/releases/latest/download/dcm2niix_lnx.zip"
    
    # Download and extract
    echo "Downloading dcm2niix"
    cd "$dir_this_dir"
    curl -L "$url_dcm2niix" -o dcm2niix.zip
    unzip -o dcm2niix.zip
    chmod +x dcm2niix
    rm dcm2niix.zip
}

InstallCreateDicom() {
    echo Not implemented
    exit 1
}

BuildPostProcessing() {
    cd "$dir_this_module"

    if [ -e env ]; then
        python -m venv env
        source ./env/Scripts/activate.sh
        pip3 install -r ./requirements.txt
    fi

    InstallDcm2niix

    InstallCreateDicom

}

cd "$dir_this_module"

SetPaths

if [ -f "$loc_qsm_apptainer_image" ]; then
    echo "Install skipped as found $loc_qsm_apptainer_image"
else
    BuildApptainerContainer
fi

BuildPostProcessing

echo "Processing Stage Install Completed"