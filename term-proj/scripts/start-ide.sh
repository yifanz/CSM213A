#!/bin/bash

CURRENT_DIR="${0%/*}"

cd $CURRENT_DIR
cd ../ide

python start.py
