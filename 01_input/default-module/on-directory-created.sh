#!/bin/bash
# Executed automatically once a dicom directory is created. See main.sh
# This can be called directly, if desired, like so:
# input/on-directory-created <directory-of-unsorted-dicoms-from-one-patient-scan-session>

set -e

# Search parameters. You can change these as needed to match your sequence names
# Note that these are not case sensitive. 
# There is no checking for multiple matching paths so make these specific 
# and only push data you want processed. Note that if paths exactly matching
# qsm / fgatir / t1 are found, these are used preferentially
qsm_name_should_match="*qsm*"
fgatir_name_should_match="*fgatir*"
t1_name_should_match="*mprage*"

# Set Paths
dir_of_this_script=$(realpath $(dirname "$BASH_SOURCE[0]"))
dir_created=$(realpath "$1")
loc_log="$dir_created/log.txt"

dir_organised_dicoms=$(mktemp -d) # this can be changed but must NOT be inside of the folder that is monitored for new dicoms
dir_fgatir="$dir_organised_dicoms/fgatir/" # Do not change
dir_qsm="$dir_organised_dicoms/qsm/" # Do not change
dir_t1="$dir_organised_dicoms/T1/" # Do not change

trap 'echo cleaning up... && [[ -d "$dir_organised_dicoms" ]] && rm -rf "$dir_organised_dicoms"' EXIT INT TERM


# Functions

CheckInputArguments() {
    if [ "$#" -ne 1 ] || [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: $0 <directory-containing-unsorted-dicoms-from-one-scan-session>"
        echo "Organises dicoms into a temp directory and calls the input-callback script to process them."
        echo "Errors are written to a log file in the provided dicom directory"
        exit 0
    fi

    # Check input dir exists
    if [ ! -d "$dir_created" ]; then
        # Bad input dir
        # Move the log location before trying to use it
        loc_log=$(realpath $(dirname "$BASH_SOURCE[0]"))/log.txt
        LogError "Provided path $dir_created does not exist or is not a directory but was provided to on-directory-created.sh"
    fi
}

Log(){
    local msg="on-directory-created.sh: $1"
    echo "$msg" # in case this script is called manually and wanting a printout in the console
    echo "$msg" >> "$loc_log"
}

LogError(){
    Log "$1"
    exit 1
}

CheckDirFound() {
    # Check if the parameter is blank or not a directory
    if [ -z "${1:-}" ] || [ ! -d "$1" ]; then
        LogError "Error: directory for $2 could not be found. Provided: $1"
        exit 1
    fi    
}

DeleteFilesOnly() {
    local dir_remove_from="$1"
    if [ -z "${dir_remove_from:-}" ]; then
        # oops. Avoid a terrible rm call
        echo "Error: directory provided is empty or not set. Check code."
        exit 1
    fi
    rm -f "$dir_remove_from/*"

}

OrganiseDicoms() {
    cp -r $dir_created $dir_organised_dicoms
    ls "$dir_organised_dicoms"
    "$dir_of_this_script/dcm2niix" -r y -f "renamed/%s_%p/%4r_%o.dcm" "$dir_organised_dicoms"
    # remove non-renamed files
    # move what's in renamed up one dir
    mv "$dir_organised_dicoms/renamed/"* $dir_organised_dicoms/
    rmdir "$dir_organised_dicoms/renamed/"

}

FindAndRenameSequenceDir() {
    # Searches for the dicoms with the exact name we want, or uses the search path for a best guess

    local dir_destination="$1"
    local description="$2"
    local search_pattern="$3"

    if [ -d "$dir_destination" ]; then
        # Found an exact match. Use preferentially
        Log "Found $description directory with exact match: $dir_destination"
    else
        local dir_best_guess=$(find "$dir_organised_dicoms" -type d -iname "$search_pattern" 2>/dev/null | tail -n 1)
        CheckDirFound "$dir_best_guess" "$description"
        Log "Best Guess at $description directory: $dir_best_guess"
        mv "$dir_best_guess" "$dir_destination"
    fi
}


# Script

CheckInputArguments "$@"

OrganiseDicoms

FindAndRenameSequenceDir "$dir_qsm" "QSM" "$qsm_name_should_match"
FindAndRenameSequenceDir "$dir_fgatir" "FGATIR" "$fgatir_name_should_match"
FindAndRenameSequenceDir "$dir_t1" "T1-MPRAGE" "$t1_name_should_match"


Log "Calling input-callback..."
bash "$dir_of_this_script/../../input-callback.sh" "$dir_organised_dicoms"