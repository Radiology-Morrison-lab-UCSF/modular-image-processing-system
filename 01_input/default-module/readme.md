# Default Input Module

This is the default module. It listens for new directories to be created in a specific location. When a directory is created, it waits a preset amount of time, then calls the input-callbash.sh to trigger processing.

## Installation

* Open `main.sh` and change the directory that is listened to to something on your system
* Change the delay time in this script to something reasonable that will always be long enough for your scanner to push all dicoms (e.g. 30mins)
* Set up your scanner/PACS so that when a push occurs, it creates a new directory in the listened-to-directory and fills it with DICOMs. 
* To ensure the script uses the sequences you want, you must edit the search parameters within `on-directory-created.sh`. Please read comments in that file before proceeding.*

## Use

After installation, push from your scanner .

Alternatively, you can directly trigger processing by calling `/input/default-module/on-directory-created.sh <full-path-to-a-directory-containing-your-unsorted-dicoms-for-one-patients-scan>` 

## Other tools

There are two utility scripts here too: `is-directory-monitoring-running.sh` and `kill-directory-monitoring.sh`. They do what their names suggest.
