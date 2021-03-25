#!/bin/sh

FMDIR=Frameworks

function build() {
	CFG=$1
	DST=$FMDIR/$CFG
	mkdir -p $DST
	ios_dir=build/Build/Products/$CFG-iphoneos
	sim_dir=build/Build/Products/$CFG-iphonesimulator
	framework_paths=`find $ios_dir -name "*.framework"`
	for f in $framework_paths; do
		echo $f
		cp -a $f $DST
	done
	
	fp0s=`find $sim_dir -name "*.framework"`
	fp1s=`find $DST -name "*.framework"`
	for f0 in $fp0s; do
		for f1 in $fp1s; do
			bf0=`basename $f0`
			bf1=`basename $f1`
			if [ $bf0 == $bf1 ]; then
				echo $bf0 " " $bf1
				ar=`basename $bf0 .framework`
				lipo $f0/$ar $f1/$ar -output $f1/$ar -create
			fi
		done
	done
}

build Debug
build Release
