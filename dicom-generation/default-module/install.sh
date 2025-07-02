#!/bin/bash
set -e

InstallDotNet() {
    
    if [[ "$1" == "--ucsf" ]]; then
        module load morrisonlab
        module load dotnet-sdk/8.0.401
    else

        echo "Downloading dotnet sdk"
        curl -sSL "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.411/dotnet-sdk-8.0.411-linux-x64.tar.gz" | tar -xz -C "$dir_dotnet"
    fi

}

dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

source "$dir_this_module/paths.sh"

SetPaths
InstallDotNet
