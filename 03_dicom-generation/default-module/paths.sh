#!/bin/bash


SetPaths() {
    local dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

    loc_create_dicom="$dir_this_module/Create-Dicom/CreateDicom.dll" # CreateDicom (not the DLL) does not work on redhat for reasons unknown
    dir_dotnet="$dir_this_module/dotnet-sdk"
    export DOTNET_ROOT="$dir_dotnet"
    export PATH="$dir_dotnet:$PATH"

}
