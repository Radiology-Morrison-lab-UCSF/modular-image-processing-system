# Modular QSM System

This code forms the foundation for a modular image processing system that contains the following stages:

* Input - recieves images (typically from PACS)
* Processing - processes images into processed NIfTI files
* Dicom conversion - converts NIfTI files into DICOMs for use in clinical software
* Output - sends images (typically to PACS)

All stages can be swapped so long as code in this repository is updated to reflect any required arguments. 

You may need some basic IT help to initially set this up. Please read this full Read Me before beginning installation.

## Getting Started

On an Ubuntu system (others may work but are untested), cd to the top directory and run `./install.sh`

Either replace the stages with your own modules, or use what is built in by default. If you choose the default set up  you will still need to customise Input and Output stages (see notes within _Default Stages_, below)

Run the system by running `./main.sh` and providing your dicoms in the way your input module expects. The default input stage will either monitor a directory for data or you can trigger processing without monitoring folders (see Default Stages for details)

## Default Stages

The default stages are listed below. 

To debug these default modules, you can read outputs in ./input/nohup.out, or in log files added to your dicom directory. 

### Input

`input/main.sh` will listen for changes to a specified folder and trigger processing when new directories of dicoms (one directory per scan session) are copied into it. **You need to customise this to point to a directory on your system.** Note that this has a default delay of one minute, which may be insufficient if your files are arriving via PACS into that directory. See the code for more details/options.

Alternatively, you can directly trigger processing by calling `/input/on-directory-created.sh <full-path-to-a-directory-containing-your-unsorted-dicoms-for-one-patients-scan>` 

**To ensure the script uses the sequences you want, you must edit the search parameters within `on-directory-created.sh`. Please read comments in that file before proceeding.**

There are two utility scripts here too: `is-directory-monitoring-running.sh` and `kill-directory-monitoring.sh`. They do what their names suggest.

### Processing

This is automatically triggered. You should not need to call this directly.

QSM images are:
1. converted into NIfTI format
2. Skull stripped using HD-BET
3. Processed via QSMxT with default settings
4. Aligned to the T1 or provided FGATIR
5. Saved as NIfTI files

### DICOM conversion

This is automatically triggered. You should not need to call this directly.

Converts processed NIfTI files into DICOMs compatible with BrainLab and StealthStation software.

### Output

This is automatically triggered. You should not need to call this directly.

Dicoms are moved to a designated folder, such as a memory stick or network drive.  

## Integrating with PACS

To integrate with PACS the Input and Output stages must be altered. There is no one-sized fits all solution for this. Contact your PACS IT for help in setting this up.

### Input

Set up a DICOM node that your scanner can push to. When DICOMs are pushed, this node should copy the files into the directory monitored by the Input module.

### Output

Monitor the output directory. When new dicom files arrive, use a storescu instance to push them to PACS.


## Disclaimer
### Subject to change

All aspects of this code base are subject to change without notice.

### Not a registered medical device

This repository and its associated code is not a registered medical device and has not undergone third-party testing or verification of any kind.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Licenses
Copyright 2025 Lee Reid and UCSF
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0