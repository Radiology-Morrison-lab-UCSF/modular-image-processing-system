#!/bin/bash
set -e

# This file should trigger processing. You can replace the internal code with anything you like
# It must run in bash and take in the following positional arguments:
# <directory-of-unprocessed-qsm-dicoms> <directory-of-fgatir-dicoms> <full-path-to-save-the-final-qsm-nifti-to>
# e.g. used like
# bash ./processing/main.sh /path/to/qsm-dicoms/ /path/to/fgatir-dicoms/ /path/to/save/final/qsm/to/qsm.nii.gz

dir_unprocessed_qsm_dicoms="$1"
dir_fgatir_dicoms="$2"
loc_processed_qsm="$3"

echo "Processing not implemented"  >&2
exit 1