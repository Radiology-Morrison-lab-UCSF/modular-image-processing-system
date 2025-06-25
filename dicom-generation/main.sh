#!/bin/bash
set -e

# This file should convert nifti files into dicom files. You can replace the internal code with anything you like
# It must run in bash and takes three positional arguments:
# <location-of-the-processed-qsm-nifti-aligned-to-the-fgatir-dicoms> <directory-of-the-fgatir-dicoms> <directory-to-output-to>
# e.g. bash ./dicom-generation/main.sh /full/path/to/qsm.nii.gz /full/path/to/fgatir/dicoms/ /full/path/to/final-qsm-dicoms/

loc_processed_qsm="$1"
dir_raw_fgatir_dicoms="$2"
dir_processed_qsm_dicoms="$3"

echo "Dicom generation not implemented"  >&2
EXIT 1