# QSM Processing Module

This default implementation processes the QSM using a combination of HD-BET and QSM-XT.

This is automatically triggered. You should not need to call this directly.

QSM images are:
1. converted into NIfTI format
2. Skull stripped using HD-BET
3. Processed via QSMxT with default settings
4. Aligned to the T1 or provided FGATIR
5. Saved as NIfTI files

## Installation

First install it by calling `./install.sh`.

If you are using GE dicoms with real/imaginary pairs, look in the `main.sh` for comments about the flag `--realimag_ge`

## Manually running

To run manually, call `./main.sh`. Read that script for correct arguments.

