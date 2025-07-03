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

## Architecture

The system is written in bash - and expects Linux. Bash is not necessarily optimal for a project of this size but does ensure that it should be editable by most people working in medical imaging, as well as hospital IT. 

This code is designed to be as modular, as readily-modifiable, and as extensible as possible. This means there are aspects that feel verbose for the default implementation. 

The basic structure is recursive. The system has:
* `./main.sh` which is the entry point to the application. 
* `./install.sh` which must be called once, before you use the application, to set it up. 
* Processing stages/modules

Each processing stage/module has the same structure:
* a `main.sh` file
* an `install.sh`.
* Potentially child stages/modules

### Install

Calling `install.sh` will call the `install.sh` of the child modules. These install the system.

e.g.
For example, consider the following set up:

```
install.sh
main.sh
    /01-preprocessing/
        install.sh
        main.sh
    /02-processing/
        install.sh
        main.sh
    /03-post-processing
        install.sh
        main.sh
```

Here `./install.sh` would probably only contain:

```
#!/bin/bash

bash ./01-preprocessing/install.sh
bash ./02-processing/install.sh 
bash ./03-postprocessing/install.sh

```

While `./01-preprocessing/install.sh` might do something like download code or install packages

```
#!/bin/bash

apt-get install some-dependency

git clone https://github.com/some-great-imaging-tool.git

```

### main.sh

`main.sh` files process collect, move, or process the imaging data.

If a parent module has child modules, `main.sh` of the parent should call the `main.sh` files of the children. 

### Syncronous
When all child `main.sh` are syncronous, they are simply called one by one by the parent `main.sh`. 

For example, consider the following set up:

```
install
main.sh
    /01-preprocessing/
        install.sh
        main.sh
    /02-processing/
        install.sh
        main.sh
    /03-post-processing
        install.sh
        main.sh
```

If all modules here are syncronous, the top `./main.sh` would consist of something like

```
#/bin/bash

# Parse inputs
input_file="$1"
working_directory="$2"

# Call child modules
bash ./01-preprocessing/main.sh "$input_file" "$working_directory"
bash ./02-processing/main.sh "$working_directory"
bash ./03-postprocessing/main.sh "$working_directory"

```

Each of `/01-preprocessing/main.sh`, `./02-processing/main.sh`, and `./03-postprocessing/main.sh` do some kind of image processing.

### Asyncronous

`main.sh` scripts can be asyncronous - that is, they return before it finishing running because they use something like `nohup` or slurm jobs.

When a child module is asyncronous, they should be provided with a callback script to execute when they complete so that processing continues in sibling modules.

For example, let us say that Step 2 in our example was asyncronous. Our solution might now look like:


The top `./main.sh`:

```
#/bin/bash

# Parse inputs
input_file="$1"
working_directory="$2"

# Call child modules
bash ./01-preprocessing/main.sh "$input_file" "$working_directory"
bash ./02-processing/main.sh "$working_directory" --callback "./03-postprocessing/main.sh"

```

`./02-processing/main.sh`:

```
#/bin/bash

# Parse inputs
working_directory="$1"
callback="$2"

# Do work and callback the next step when completed
nohup bash -c "process-image.sh $working_directory && \
                \"$callback\" \"$working_directory\""

```

## Default Stages

The default stages each have their own README.md file. See those directories for detail on how they function. In brief:

1. You call `./main.sh` without arguments
1. The input stage sets up listening for new directories of dicoms in a location on your system. It is an asyncronous module and will execute the next stages every time a new directory is created. 
1. The processing stage processes QSM images, the result being a collection of nifti files. `
1. The dicom generation stage converts the processed QSM into a new DICOM series
1. The output stage moves these to a network location where they will automatically be pushed to PACS.

### Debugging the default stages

To debug these default modules, you can read outputs in ./input/nohup.out, or in log files added to your dicom directory. 

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