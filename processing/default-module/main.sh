#!/bin/bash
set -e

# This file processess QSM images
# It must run in bash and take in the following positional arguments:
# <directory-of-unprocessed-qsm-dicoms> <directory-of-fgatir-dicoms> <full-path-to-save-the-final-qsm-nifti-to>
# e.g. used like
# bash ./main.sh /path/to/qsm-dicoms/ /path/to/t1-dicoms/ /path/to/fgatir-dicoms/ /path/to/save/final/qsm/to/qsm.nii.gz

dir_input_unprocessed_qsm_dicoms="$1"
dir_input_t1_dicoms="$2"
dir_input_fgatir_dicoms="$3"
loc_processed_qsm="$4"

dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

# Set up paths
dir_working=$(mktemp -d)
trap 'echo cleaning up... && [[ -d "$dir_working" ]] && rm -rf "$dir_working"' EXIT INT TERM
source "$dir_this_module/paths.sh"
SetPaths "$dir_working"

ln -s "$dir_input_t1_dicoms" "$loc_dicoms_t1"
ln -s "$dir_input_fgatir_dicoms" "$loc_dicoms_fgatir"
ln -s "$dir_input_qsm_dicoms" "$loc_dicoms_qsm"

# Run QSM XT with extra skull stripping
# Add --realimag_ge to the apptainer arguments if you are using GE with real/imag images
mkdir -p "$dir_working"
apptainer run --cleanenv --no-home --nv --bind "$dir_working" "$loc_qsm_apptainer_image" --dicoms "$loc_dicoms_raw" --out "$dir_qsmxt_out"

# Align with FGATIR and create dicoms
cp "$dir_this_module/"
source ./env/Scripts/activate.sh
ls "$dir_working"
ls "$dir_out"
exit 1
python -m main  

exit 1