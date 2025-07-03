# This file should run any installation your processing stage requires
# You can replace its content. It must run in bash and take in no arguments

echo "Processing Stage Install Beginning"

dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

bash "$dir_this_module/default-module/install.sh"
