#!/bin/bash
set -e

# This file should convert nifti files into dicom files. You can replace the internal code with anything you like
# It must run in bash.
# See the default-module for currently expected arguments use

bash $(realpath $(dirname "$BASH_SOURCE[0]"))/default-module/main.sh "$@"
