# Modular QSM System

This code forms the foundation for a modular image processing system that contains the following stages:

* Input - recieves images (typically from PACS)
* Processing - processes images into processed NIfTI files
* Dicom conversion - converts NIfTI files into DICOMs for use in clinical software
* Output - sends images (typically to PACS)

All stages can be swapped so long as code in this repository is updated to reflect any required arguments. 

You may need some basic IT help to initially set this up. Please read this full Read Me before beginning installation.

## Default Stages

The default stages are as follows:

### Input

Manually copy DICOM files from a memory stick or network drive into the designated folder. Code will organise your dicoms and trigger the processing stage.

### Processing

QSM images are:
1. converted into NIfTI format
2. Skull stripped using HD-BET
3. Processed via QSMxT with default settings
4. Aligned to the T1 or provided FGATIR
5. Saved as NIfTI files

This will then trigger DICOM conversion.

### DICOM conversion

Converts processed NIfTI files into DICOMs compatible with BrainLab and StealthStation software.

### Output

Dicoms are moved to a designated folder, such as a memory stick or network drive.  

## Integrating with PACS

To integrate with PACS the Input and Output stages must be altered. There is no one-sized fits all solution for this. Contact your PACS IT for help in setting this up.

### Input

Set up a DICOM node that your scanner can push to. When DICOMs are pushed, this node should copy the files into the directory monitored by the Input module.

### Output

Monitor the output directory. When new dicom files arrive, use a storescu instance to push them to PACS.


## Disclaimer
### Subject to change

All public interfaces are subject to change without notice.

### Not a registered medical device

This repository and its associated code is not a registered medical device and has not undergone third-party testing or verification of any kind.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Licenses
Copyright 2025 Lee Reid and UCSF
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0