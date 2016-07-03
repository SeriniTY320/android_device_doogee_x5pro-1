#!/bin/sh

MYABSPATH=$(readlink -f "$0")
PATCHBASE=$(dirname "$MYABSPATH")
CMBASE=$(readlink -f "$PATCHBASE/../../../../")

for i in $(find "$PATCHBASE"/* -type d); do
	PATCHTARGET=$(basename "$i")
	for i in $(seq 4); do
		PATCHTARGET=$(echo $PATCHTARGET | sed 's/_/\//')
		if [ -d "$CMBASE/$PATCHTARGET" ]; then break; fi
	done

	echo -n "Cleaning $PATCHTARGET... "
	cd "$CMBASE/$PATCHTARGET" || ( echo "[ ERROR ]" && echo 1 && exit 1 )
	git reset -q --hard || ( echo "[ ERROR ]" && echo 1 && exit 1 )
	git clean -qfdx || ( echo "[ ERROR ]" && echo 1 && exit 1 )
	git am --abort
	repo sync "$CMBASE/$PATCHTARGET" --force-sync
	echo " [ OK ]"
done
