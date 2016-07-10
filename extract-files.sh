#!/bin/sh

## usage: extract-files.sh $1 $2
## $1 and $2 are optional
## if $1 = unzip the files will be extracted from zip file (if $1 = anything else 'adb pull' will be used
## $2 specifies the zip file to extract from (default = ../../../${DEVICE}_update.zip)

VENDOR=doogee
DEVICE=x5pro

BASE=../../../vendor/$VENDOR/$DEVICE/proprietary
rm -rf $BASE/*

if [ -z "$2" ]; then
	ZIPFILE=../../../${DEVICE}_update.zip
else
	ZIPFILE=$2
fi

if [ "$1" = "unzip" -a ! -e $ZIPFILE ]; then
	echo $ZIPFILE does not exist.
else
	for FILE in `cat proprietary-files.txt | grep -v ^# | grep -v ^$`; do
		DIR=`dirname $FILE`
		if [ ! -d $BASE/$DIR ]; then
			mkdir -p $BASE/$DIR
		fi
		if [ "$1" = "unzip" ]; then
			unzip -j -o $ZIPFILE $FILE -d $BASE/$DIR
		else
			adb pull $FILE $BASE/$FILE
		fi
	done

	deodex_list=$(cat proprietary-deodex-files.txt | grep -v ^# | grep -v ^$)
	if [ -n "${deodex_list}" ]; then
		BASE=$(realpath $BASE)
		ZIPFILE=$(realpath $ZIPFILE)
		FRAMEWORK_TEMP_DIR=$(mktemp -d)
		mkdir -p "${FRAMEWORK_TEMP_DIR}"/system
		mkdir -p "${FRAMEWORK_TEMP_DIR}"/system/smali
		if [ "$1" = "unzip" ]; then
			unzip  -o $ZIPFILE system/framework/* -d "${FRAMEWORK_TEMP_DIR}"
		else
			adb pull system/framework "${FRAMEWORK_TEMP_DIR}"
		fi

		pushd "${FRAMEWORK_TEMP_DIR}"/system
		oat2dex devfw framework/
		echo '#######################'
		echo '# Ignore above steps! #'
		echo '#######################'
		for FILE in $deodex_list; do
			DIR=`dirname $FILE`
			APK_NAME=`basename $FILE`
			FILENAME="${APK_NAME%.*}"
			if [ ! -d "$BASE/$DIR" ]; then
				mkdir -p "$BASE/$DIR"
			fi

			if [ "${DIR}" = "system/framework" ]; then
				echo Processing Java library "${APK_NAME}"

				TARGET_DIR=boot-jar-result
				if [ ! -f boot-jar-result/"${APK_NAME}" ]; then
					TARGET_DIR=framework-jar-with-dex
				fi

				cp "${TARGET_DIR}"/"${APK_NAME}" "$BASE/$DIR"
			else
				if [ "$1" = "unzip" ]; then
					unzip -o $ZIPFILE "$DIR"/* -d "${FRAMEWORK_TEMP_DIR}"
				else
					adb pull "$DIR" "${FRAMEWORK_TEMP_DIR}"
				fi

				oat2dex ../"${DIR}"/arm/"${FILENAME}".odex odex/
				baksmali -a 22 -x ../"${DIR}"/arm/"${FILENAME}".dex -d framework/ -o smali/
				smali smali/ -o classes.dex
				zip -gjq ../"${FILE}" classes.dex
				cp ../"${FILE}" "$BASE/$DIR"

				rm -r smali/*
				rm classes.dex
			fi
		done
		popd

		rm -r "${FRAMEWORK_TEMP_DIR}"/*
		rmdir "${FRAMEWORK_TEMP_DIR}"
	fi
fi
./setup-makefiles.sh
