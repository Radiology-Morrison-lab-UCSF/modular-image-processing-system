#!/bin/bash

set -e

./01_input/install.sh
./02_processing/install.sh
./03_dicom-generation/install.sh
./04_output/install.sh

echo "Installation complete"