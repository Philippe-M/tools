#!/bin/bash
# Recherche un nom de fichier dans une colonne du fichier csv
# et renomme le fichier par la valeur d'une autre colonne du fichier csv
# auteur : Philippe MALADJIAN
# version : 0.1

DIRSRC="/home/xxxx/Bureau/export"
DIROUT="/home/xxxx/Bureau/export"

echo . > "mouvRename.log"
for FILE in `ls ${DIRSRC}`
do
	FILENAME=`basename ${FILE} | cut -d"." -f1`
	FILEEXT=`basename ${FILE} | cut -d"." -f2`

	while read LINE
	do
		REFHIL=`echo ${LINE} | cut -d";" -f1`
		EANHIL=`echo ${LINE} | cut -d";" -f2`
		if [ "${REFHIL}" == "${FILENAME}" ]
		then
			echo "FILENAME = ${FILENAME} | FILEEXT = ${FILEEXT} | REFHIL = ${REFHIL} | EANHIL = $EANHIL | ** ${EANHIL}.${FILEEXT}" >> "anael.log"
			mv "${DIRSRC}/${FILENAME}.${FILEEXT}" "${DIROUT}/${EANHIL}.${FILEEXT}"
		fi
	done < "mouvRename.csv"
done
