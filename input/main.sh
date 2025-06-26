#!/bin/bash
set -e

# This file should find raw dicoms from the scanner and call ../input-callback.sh when these are found. It can do this as many times as is needed.
# You can replace the internal code with anything you like
# It must run in bash and takes no arguments
# e.g. bash ./input/main.sh

# -------------------------------------------------------------------------
# Default implementation that simply watches for new directories to be 
# created is below. If you want to use this implementation, you need to 
# replace the dir_to_watch value with a path on your system where you will
# copy folders of dicoms to. Do not copy dicoms straight into this folder
# but instead copy a _folder_ of dicoms in or it will not pick up the change
# ----------------------------------------------------------------------------

dir_of_this_script=$(realpath $(dirname "$BASH_SOURCE[0]"))/

dir_to_watch="/data/dicom/"

# This will call on-directory-created.sh one minute after a new directory is made
# If you are pushing from a scanner, change that 1 minute to a much longer period
# that is much longer than it takes to push your images, or this will be triggered
# before your images have completed pushing. 
# For example, you could set it to 30 minutes by changing it to 0:30:00
nohup "$dir_of_this_script"/DirectoryCreatedWatcher 0:01:00 dcm2niix -r y bash "$dir_of_this_script/on-directory-created.sh" &

echo "Listening for new directories to be added to $dir_to_watch"