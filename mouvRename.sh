#!/bin/bash
# Recherche un nom de fichier dans une colonne du fichier csv
# et renomme le fichier par la valeur d'une autre colonne du fichier csv
# auteur : Philippe MALADJIAN
# version : 0.1
SRC="/src"
DIRSRC="${SRC}/Photos"
DIROUT="${SRC}/export"

echo . > "${SRC}/mouvRename.log"
# Parcours du dossier DIRSRC
for FILE in `ls ${DIRSRC}`
do
	ERREUR=1
	# Extraction du nom du fichier
	FILENAME=`basename ${FILE} | cut -d"." -f1`
	# Extraction de l'extention du fichier
	FILEEXT=`basename ${FILE} | cut -d"." -f2`

	echo "FILENAME : "${FILENAME}
	# Lecture du fichier csv
	while read LINE
	do
		# Extraction de la référence
		REF=`echo ${LINE} | cut -d";" -f1`
		# Extraction du gencod
		EAN=`echo ${LINE} | cut -d";" -f2`
		# mettre un seul = pour faire une recherche en contient
		# mettre deux = pour faire une recherche exacte
		if [[ "${FILENAME}" == *"${REF}"* ]]
		then
			echo ${REF}"---"${EAN}"----"${FILENAME}
			echo "FILENAME = ${FILENAME} | FILEEXT = ${FILEEXT} | REF = ${REF} | EAN = $EAN | ** ${EAN}.${FILEEXT}" >> "${SRC}/mouvRename.log"
			# ----- Décommenter la ligne suivant le mode de renommage (EAN ou REFERENCE) ---- #
			mv "${DIRSRC}/${FILENAME}.${FILEEXT}" "${DIROUT}/${EAN}.${FILEEXT}"
			#mv "${DIRSRC}/${FILENAME}.${FILEEXT}" "${DIROUT}/${REF}.${FILEEXT}"
			ERREUR=0
		fi
	done < "${SRC}/file.csv"
	if [ ${ERREUR} == 1 ]
	then
		ERREUR=0
		echo "Pas de correspondance pour le fichier ${FILENAME}.${FILEEXT}" >> "${SRC}/mouvRename-error.log"
	fi
done
