#!/bin/bash


if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0"
  echo "Finds and kills processes that are monitoring directories (anything named 'DirectoryCreate') run by the current user."
  exit 0
fi

uid=$(id -u)
pids=$(ps --user "$uid" -o pid=,comm= | awk '$2=="DirectoryCreate" {print $1}')

if [ -n "$pids" ]; then
  kill $pids
  echo "Killed processes: $pids"
else
  echo "No DirectoryCreate processes found."
fi
