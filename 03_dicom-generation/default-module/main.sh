#!/bin/bash

set -e

source "$(realpath $(dirname "$BASH_SOURCE[0]"))/paths.sh"

loc_processed_qsm="$1"
dir_raw_fgatir="$2"
dir_dicoms_out="$2"

PrintUsage() {
    echo "Usage: $0 --processed-qsm FILE --fgatir-dicoms-dir DIR --out-dir DIR"
    exit 1    
}

ParseArgs() {
    
    loc_processed_qsm=""
    dir_raw_fgatir=""
    dir_dicoms_out=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --processed-qsm)
                loc_processed_qsm="$2"; shift 2;;
            --fgatir-dicoms-dir)
                dir_raw_fgatir="$2"; shift 2;;
            --out-dir)
                dir_dicoms_out="$2"; shift 2;;
            *)
                echo "Unknown option: $1"; PrintUsage;;
        esac
    done

    if [[ -z "$loc_processed_qsm" || -z "$dir_raw_fgatir" || -z "$dir_dicoms_out" ]]; then
        PrintUsage
    fi
}


SetPaths

ParseArgs "$@"

mkdir -p "$dir_dicoms_out"

echo "--------------------------------------------------------------------------------------------------"
echo "Potentially not implemented properly - this is using the first dicom found. It might need the most"
echo "superior or inferior slice. Experiment to see if this is smart enough to get it right no matter"
echo "what you give it. If your results differ, then you need to be cleverer about which file first_dicom is"
echo "--------------------------------------------------------------------------------------------------"

first_dicom=$(find "$dir_raw_fgatir" -maxdepth 1 -type f | sort | head -n 1)
dotnet "$loc_create_dicom" "$first_dicom" "$loc_processed_qsm" "$dir_dicoms_out" "QSM-Aligned-To-FGATIR" --normalise
