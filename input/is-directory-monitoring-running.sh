#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0"
  echo "Checks if 'DirectoryCreate' processes exist for the current user. If they are, it is assumed this is for this system"
  exit 0
fi

uid=$(id -u)
found=$(ps --user "$uid" -o comm= | grep -w "DirectoryCreate")

if [ -n "$found" ]; then
  echo "DirectoryCreate processes found. This suggests that directory monitoring is working."
else
  echo "No DirectoryCreate processes found. The system is not monitoring directories for new DICOMs"
fi
