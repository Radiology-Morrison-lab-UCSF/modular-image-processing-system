#!/bin/bash
set -e

# This file should run any installation your input stage requires
# You can replace its content. It must run in bash and take in no arguments
bash $(realpath $(dirname "$BASH_SOURCE[0]"))/default-module/install.sh