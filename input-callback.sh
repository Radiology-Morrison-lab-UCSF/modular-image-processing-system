#!/bin/bash
set -e

# Executed when input completes to run all other stages of the pipeline
# Call as:
# callback-input.sh /full/path/to/sorted-dicoms
# This path should have two directories:
#       fgatir/<all fgatir dicom files>
#       qsm/<all qsm dicom files>
#       T1/<all qsm dicom files>


dir_sorted_dicoms=$(realpath "$1")

dir_raw_qsm="$dir_sorted_dicoms"/qsm/
dir_raw_fgatir="$dir_sorted_dicoms"/fgatir/
dir_raw_t1="$dir_sorted_dicoms"/T1/


dir_processed_qsm=$(mktemp -d)
loc_processed_qsm="$dir_processed_qsm"/qsm.nii.gz

dir_processed_qsm_dicoms="$dir_processed_qsm"/dicoms/

# Auto-delete temp files when we exit
trap "rm -rf \"$dir_processed_qsm\"" EXIT

echo "Running QSM Processing"
bash $(dirname "$BASH_SOURCE[0]")/processing/main.sh "$dir_raw_qsm" "$dir_raw_t1" "$dir_raw_fgatir" "$loc_processed_qsm"


echo "Running Dicom Generation"
bash $(dirname "$BASH_SOURCE[0]")/dicom-generation/main.sh "$loc_processed_qsm" "$dir_raw_fgatir" "$dir_processed_qsm_dicoms"


echo "Sending Output"
bash $(dirname "$BASH_SOURCE[0]")/output/main.sh "$dir_processed_qsm_dicoms"

echo "Done"