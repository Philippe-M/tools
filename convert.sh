#!/bin/bash
BASE="${1}"
SRC="${2}"
OUT="${3}"

if [ -z ${1} ] 
then
	echo "Le répertoire base est obligatoire sans les / de fin"
	echo "convert.sh [base] [source] [out]"
	echo "convert.sh /home/user preview thumbnail"
	exit 1
fi

if [ -z ${2} ] 
then
	echo "Le répertoire source est obligatoire sans les / de fin"
	echo "convert.sh [base] [source] [out]"
	echo "convert.sh /home/user preview thumbnail"
	exit 1
fi

if [ -z ${3} ]
then
        echo "Le répertoire destination est obligatoire sans les / de fin"
        echo "convert.sh [base] [source] [out]"
        echo "convert.sh /home/user preview thumbnail"
        exit 1
fi

for FILE in `ls ${BASE}/${SRC}`
do

	if [ -f ${BASE}/${SRC}/${FILE} ]
	then
		FILENAME=`basename ${FILE} | cut -d"." -f1`
		EXTNAME=`basename ${FILE} | cut -d"." -f2`
		if [ $EXTNAME = "png" ] || [ $EXTNAME = "jpg" ] || [ $EXTNAME = "jpeg" ]
		then
		echo "Conversion du fichier ${FILE}"
			convert -sampling-factor 4:2:0 \
				-strip \
				-interlace JPEG \
				-colorspace sRGB \
				-quality 85% \
				-resample 72 \
				-units PixelsPerInch \
				-resize 120x120 \
				${BASE}/${SRC}/${FILE} \
				${BASE}/${OUT}/${FILENAME}.${EXTNAME}
			exiftool -all= ${BASE}/${OUT}/${FILENAME}.${EXTNAME}
		fi
	fi
done


exit 0
