#!/bin/bash
set -e

# This file should send the final dicoms to their destination - e.g. to PACS. You can replace the internal code with anything you like
# It must run in bash and takes in only one positional argument: the location the final dicoms can be found in
# e.g. bash ./output/main.sh /full/path/to/processed-qsm-dicoms/ 
# This script must assume that the provided directory will be deleted once it exits


dir_processed_dicoms="$1"

echo "Output not implemented"  >&2
EXIT 1