#!/bin/bash
set -e

# This file should trigger processing. You can replace the internal code with anything you like
# It must run in bash and take in the following positional arguments:
# <directory-of-unprocessed-qsm-dicoms> <directory-of-fgatir-dicoms> <full-path-to-save-the-final-qsm-nifti-to>
# e.g. used like
# bash ./processing/main.sh /path/to/qsm-dicoms/ /path/to/t1-dicoms/ /path/to/fgatir-dicoms/ /path/to/save/final/qsm/to/qsm.nii.gz

dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

# Optionally, you can enter additional logic that inspects the provided files to choose which processing pipeline
# should be execute. Currently it always assumes the default pipeline is appropriate
bash "$dir_this_module/default-module/main.sh" "$@"