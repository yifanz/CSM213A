#!/bin/bash

CURRENT_DIR="${0%/*}"

cd $CURRENT_DIR

sudo ./activate-pruss.sh
sudo ./install-BBB-kernel-headers.sh
if ! lsmod | grep --quiet pin_pirate; then
	echo pin-pirate LKM not loaded 
	pushd .
	cd ../driver	
	make load
	popd
else
	echo pin-pirate LKM loaded
fi

cd ../ide

python start.py
