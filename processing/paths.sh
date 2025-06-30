#!/bin/bash


SetPaths() {
    local dir_tmp="$1"
    local dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/


    loc_qsm_apptainer_image="$dir_this_module/qsm-processing-pipeline.sif"

    loc_dicoms_raw="$dir_tmp/in/dicoms/"
    loc_dicoms_t1="$loc_dicoms_raw/T1/"
    loc_dicoms_qsm="$loc_dicoms_raw/qsm/"
    loc_dicoms_fgatir="$loc_dicoms_raw/fgatir/"

    dir_qsmxt_out="$dir_tmp/out/qsmxt/"
    dir_dicoms_out="$dir_tmp/out/qsm-dicoms/"
}
