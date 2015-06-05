#!/bin/bash
# Recherche un nom de fichier dans une colonne du fichier csv
# et renomme le fichier par la valeur d'une autre colonne du fichier csv
# auteur : Philippe MALADJIAN
# version : 0.1

DIRSRC="/home/xxx/Bureau/export/src"
DIROUT="/home/xxx/Bureau/export/out"

echo . > "cpRename.log"
# Parcours du dossier DIRSRC
for FILE in `ls ${DIRSRC}`
do
	# Extraction du nom du fichier
	FILENAME=`basename ${FILE} | cut -d"." -f1`
	# Extraction de l'extention du fichier
	FILEEXT=`basename ${FILE} | cut -d"." -f2`

	# Lecture du fichier mouvRename.csv
	while read LINE
	do
		# Extraction de la référence
		REFHIL=`echo ${LINE} | cut -d";" -f1`
		# Extraction du gencod
		EANHIL=`echo ${LINE} | cut -d";" -f2`
		if [ "${REFHIL}" == "${FILENAME}" ]
		then
			echo "FILENAME = ${FILENAME} | FILEEXT = ${FILEEXT} | REFHIL = ${REFHIL} | EANHIL = $EANHIL | ** ${EANHIL}.${FILEEXT}" >> "cpRename.log"
			# ---- Décommenter la ligne suivant le mode de renommage (EAN ou REFERENCE) --- #
			#cp "${DIRSRC}/${FILENAME}.${FILEEXT}" "${DIROUT}/${EANHIL}.${FILEEXT}"
			#cp "${DIRSRC}/${FILENAME}.${FILEEXT}" "${DIROUT}/${REFHIL}.${FILEEXT}"
		fi
	done < "cpRename.csv"
done
