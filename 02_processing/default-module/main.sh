#!/bin/bash
set -e

# This file processess QSM images
# It must run in bash and take in the following positional arguments:
# <directory-of-unprocessed-qsm-dicoms> <dir-t1-dicoms> <dir-fgatir-dicoms> <full-path-to-save-the-final-qsm-nifti-to> [full-path-a-working-dir (optional)]
# e.g. used like
# bash ./main.sh /path/to/qsm-dicoms/ /path/to/t1-dicoms/ /path/to/fgatir-dicoms/ /path/to/save/final/qsm/to/qsm.nii.gz

ParseInputs() {

  if [[ $# -lt 4 || $# -gt 5 ]]; then
    echo "Usage: $0 <dir-unprocessed-qsm-dicoms> <dir-t1-dicoms> <dir-fgatir-dicoms> <loc-final-result> [dir-working]"
    exit 1
  fi

  dir_input_unprocessed_qsm_dicoms="$1"
  dir_input_t1_dicoms="$2"
  dir_input_fgatir_dicoms="$3"
  loc_final_qsm="$4"
  dir_working="$5"

  dir_this_module=$(realpath $(dirname "$BASH_SOURCE[0]"))/

  # Check provided dirs exist
  for dir in "$dir_input_unprocessed_qsm_dicoms" "$dir_input_t1_dicoms" "$dir_input_fgatir_dicoms"; do
    if [[ ! -d "$dir" ]]; then
      echo "Error: '$dir' does not exist or is not a directory."
      exit 1
    fi
  done
}

CreateWorkingDir() {
  # Set up paths
  if [[ -z "$dir_working" ]]; then
    dir_working=$(mktemp -d)
    trap 'echo cleaning up... && [[ -d "$dir_working" ]] && rm -rf "$dir_working"' EXIT INT TERM
    echo "No working directory provided. Created temporary directory which will be automatically deleted: $dir_working"
  else
    mkdir -p "$dir_working"
    echo "Working directory provided. This will not automatically be cleaned up"
  fi
}

RunQSMXTPipeline() {

  # Copy files into a structure expected by the qsm pipeline
  # Note that we can't use ln here reliably as apptainer often
  # cannot resolve the paths 
  mkdir -p "$dir_dicoms_raw"
  cp -rn "$dir_input_t1_dicoms" "${dir_dicoms_t1%/}"
  cp -rn "$dir_input_fgatir_dicoms" "${dir_dicoms_fgatir%/}"
  cp -rn "$dir_input_unprocessed_qsm_dicoms" "${dir_dicoms_qsm%/}"

  # Check if this has completed already
  if [[ -f "$loc_qsmxt_qsm_brainmask" && -f "$dir_qsmxt_out/$fn_qsmxt_qsm_processed" && -f "$loc_qsmxt_t1" && -f "$loc_qsmxt_t1_brainmask" && -f "$loc_qsmxt_t1ToQSM" ]]; then
    echo "QSM-XT outputs found. Processing skipped"
    return
  fi

  # The pipeline mounts our working directory so it needs relative paths to that dir
  dir_dicoms_raw_relative="${dir_dicoms_raw#$dir_working/}"
  dir_qsmxt_out_relative="${dir_qsmxt_out#$dir_working/}"
  
  # Julia forcibly tries to write to home, spoiling containerisation if we let it
  # So we instead bind home to somewhere else
  rm -rf "$dir_fake_home"
  mkdir -p "$dir_fake_home/$USER"
  
  # Add --realimag_ge to the apptainer arguments if you are using GE with real/imag images
  apptainer run --cleanenv --no-home --nv  --bind "$dir_fake_home":/home/  --cwd /opt/ --bind "$dir_working":/working/ "$loc_qsm_apptainer_image" --dicoms "/working/$dir_dicoms_raw_relative" --out "/working/$dir_qsmxt_out_relative"

}

AlignWithFGATIR() {

  cd "$dir_this_module"
  source ./env/bin/activate
  mkdir -p "$dir_aligned_qsm_out"
  python -m main --dir_input_dicoms "$dir_dicoms_raw" --dir_input_qsmxt "$dir_qsmxt_out" --qsm_filename "$fn_qsmxt_qsm_processed" --output_dir "$dir_aligned_qsm_out" --dcm2niix "$loc_dcm2niix"

  echo "Alignment complete"
}

ParseInputs "$@"

CreateWorkingDir

source "$dir_this_module/paths.sh"
SetPaths "$dir_working"

RunQSMXTPipeline

AlignWithFGATIR

if [[ "$loc_final_qsm" == *.nii.gz ]]; then
  gzip -c "$dir_aligned_qsm_out/qsm-post-processed.nii" > "$loc_final_qsm"
else
  cp "$dir_aligned_qsm_out"/qsm-post-processed.nii" $loc_final_qsm"
fi