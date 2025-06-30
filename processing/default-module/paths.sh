#!/bin/bash


SetPaths() {
    local dir_tmp="$1"
    local dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

    loc_dcm2niix="$dir_this_module/dcm2niix"

    loc_qsm_apptainer_image="$dir_this_module/qsm-processing-pipeline.sif"

    loc_dicoms_raw="$dir_tmp/in/dicoms/"
    loc_dicoms_t1="$loc_dicoms_raw/T1/"
    loc_dicoms_qsm="$loc_dicoms_raw/qsm/"
    loc_dicoms_fgatir="$loc_dicoms_raw/fgatir/"


    dir_out="$dir_tmp/out/"
    loc_t1_qsmSpace="$dir_out/t1.nii"
    loc_qsm_brainmask="$dir_out/"qsm-brainmask.nii.gz"
    

        self.loc_qsm = os.path.join(dir_input,  filename_qsm)
        self.loc_t1_qsmSpace = os.path.join(dir_input,  "t1.nii")
        self.loc_qsm_brainmask = os.path.join(dir_input,  "qsm-brainmask.nii.gz")
        self.dir_fgatir_dicoms = os.path.join(dir_input, "dicoms", "fgatir")
        self.dir_qsm_dicoms = os.path.join(dir_input, "dicoms", "qsm")


    dir_qsmxt_out="$dir_tmp/out/qsmxt/"
    dir_dicoms_out="$dir_tmp/out/qsm-dicoms/"
}
