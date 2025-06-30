#!/bin/bash

set -e

./input/install.sh
./processing/install.sh
./dicom-generation/install.sh
./output/install.sh

echo "Installation complete"