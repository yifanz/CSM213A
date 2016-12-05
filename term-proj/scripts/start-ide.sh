#!/bin/bash

CURRENT_DIR="${0%/*}"

cd $CURRENT_DIR

sudo ./activate-pruss.sh

cd ../ide

python start.py
