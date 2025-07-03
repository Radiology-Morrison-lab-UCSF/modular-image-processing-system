#!/bin/bash


SetPaths() {
    # Provide a path to a temporary directory to set file paths
    # other than executables.
    local dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

    loc_dcm2niix="$dir_this_module/dcm2niix"
    loc_qsm_apptainer_image="$dir_this_module/qsm-processing-pipeline.sif"

    if [ "$#" -gt 0 ]; then
        local dir_tmp="$1"

        # Fake home is a writeable temp directory that apptainer thinks 
        # is home. This avoids Julia reading/writing from our actual home
        # directory, which causes instability and spoils containerisation
        dir_fake_home="$dir_tmp/fake-home/"

        dir_dicoms_raw="$dir_tmp/in/dicoms/"
        dir_dicoms_t1="$dir_dicoms_raw/t1/"
        dir_dicoms_qsm="$dir_dicoms_raw/qsm/"
        dir_dicoms_fgatir="$dir_dicoms_raw/fgatir/"

        dir_out="$dir_tmp/out/"
        loc_t1_qsmSpace="$dir_out/t1.nii"
        
        # Extended QSM XT pipeline results
        dir_qsmxt_out="$dir_tmp/out/qsmxt/"
        loc_qsmxt_qsm_brainmask="$dir_qsmxt_out/qsm-brainmask.nii.gz"
        fn_qsmxt_qsm_processed="sub-mysubj_Chimap.nii"
        loc_qsmxt_t1="$dir_qsmxt_out/t1.nii"
        loc_qsmxt_t1_brainmask="$dir_qsmxt_out/t1-brainmask.nii.gz"
        loc_qsmxt_t1ToQSM="$dir_qsmxt_out/t1-to-qsm.mat"

        dir_aligned_qsm_out="$dir_tmp/out/qsm-aligned/"
    fi
}
