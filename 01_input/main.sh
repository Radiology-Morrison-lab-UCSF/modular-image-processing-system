#!/bin/bash
set -e

# This file should find raw dicoms from the scanner and call ../input-callback.sh when these are found. It can do this as many times as is needed.
# You can replace the internal code with anything you like
# It must run in bash and takes no arguments
# e.g. bash ./input/main.sh

# call the default module's main method
dir_of_this_script=$(realpath $(dirname "$BASH_SOURCE[0]"))/
bash "$dir_of_this_script/default-module/main.sh"