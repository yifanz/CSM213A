#!/bin/bash

CURRENT_DIR="${0%/*}"

cd $CURRENT_DIR

TMP_DIR="../ide/_tmp/"

if [ -d "$TMP_DIR" ]; then
	cd $TMP_DIR

	cp ../../pru-loader/pru_loader.c .
	gcc -std=c99 -o pru_loader pru_loader.c -lprussdrv

	if [ $? -ne 0 ]; then
		exit 1
	fi

	pasm -b "pru_$1.p"

	if [ $? -ne 0 ]; then
		exit 1
	fi

	if [ "$2" = "run" ]; then
		./pru_loader "pru_$1.bin" "$1"
	fi
fi


