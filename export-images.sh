#!/bin/bash

# Copie des fichiers hautes définitions par rapport à un
# fichier contenant uniquement le nom des fichiers sans extension

ROOT="/root"
SRC="/www/prod/gallerie/html"
OUT="/www/prod/gallerie/html/galleries/export"
FILE="$ROOT/export.csv"
MYSQLDIR=$(which mysql)
DIRNAMEDIR=$(which dirname)
CPDIR=$(which cp)
SEDDIR=$(which sed)
BASENAMEDIR=$(which basename)
RMDIR=$(which rm)
WCDIR=$(which wc)
BCDIR=$(which bc)
CUTDIR=$(which cut)
USER="pwg"
PASS="FZ886ZiP"
I=1
NBLIGNE=0

RM=`$RMDIR $ROOT/export.log`
if [ $? -ne 0 ]
then
	echo "Impossible de supprimer le fichier $ROOT/export.log"
	fi

	NBLIGNE=`$WCDIR -l $FILE | $CUTDIR -d" " -f1`

	while read LIGNE
	do
		RESULT=`$MYSQLDIR -h localhost --user=$USER --password=$PASS -B -s -e "SELECT path FROM phpwebgallery_images WHERE name='$LIGNE'" phpwebgallery_prod`
		if [ $RESULT ]
		then
			DIR=`$DIRNAMEDIR $RESULT`
			FILE=`$BASENAMEDIR $RESULT`
			DIR=`echo $DIR | $SEDDIR 's/\.\///'`
			CP=`$CPDIR $SRC/$DIR/pwg_high/$FILE $OUT`
			if [ $? -ne 0 ]
			then
				echo "Une erreur c'est produite pendant la copie du fichier $FILE" >> $ROOT/export.log
			fi
		else
			echo "Pas d'image pour la référence $LIGNE" >> $ROOT/export.log
		fi
		PROGRESS=`$BCDIR -l <<< "($I/$NBLIGNE)*100" | $CUTDIR -d"." -f1`
		echo -ne "Progression : $PROGRESS%\r"

		let "I=$I+1"
	done < $FILE
exit 0
