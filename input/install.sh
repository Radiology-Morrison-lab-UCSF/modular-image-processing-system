#!/bin/bash
set -e

# This file should run any installation your input stage requires
# You can replace its content. It must run in bash and take in no arguments

# ----------------------------------------------------------------
# Below calls the default installation for an executable that watches a 
# directory and calls input-callback when this occurs



dir_this_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))/
bash "$dir_this_dir"/default-module/install.sh

echo "Input Stage Install Complete"