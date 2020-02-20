#!/bin/bash
# Recherche un nom de fichier dans une colonne du fichier csv
# et renomme le fichier par la valeur d'une autre colonne du fichier csv
# auteur : Philippe MALADJIAN
# version : 0.3

BASE=""
DIRSRC=""
DIROUT=""
COLSRC=""
COLDEST=""
SUFFIX=""
PREFIX=""
CONVERT=""
QUALITY=""
RESAMPLE=""
FILESRC=""

while getopts "b:s:d:e:t:f:p:c:q:a:r:" option
do
	case "${option}"
	in
		b) BASE="${OPTARG}";;
		s) DIRSRC="${OPTARG}";;
		d) DIROUT="${OPTARG}";;
		e) COLSRC="${OPTARG}";;
		t) COLDEST="${OPTARG}";;
		f) SUFFIX="${OPTARG}";;
		p) PREFIX="${OPTARG}";;
		c) CONVERT="${OPTARG}";;
		q) QUALITY="${OPTARG}";;
		a) RESAMPLE="${OPTARG}";;
		r) FILESRC="${OPTARG}";;
		:)
			echo "L'option ${OPTARG} requiere un argument"
			exit 1
			;;
	esac
done

function usage { 
	echo ""
        echo "mouvRename.sh -b [base] -s [source] -d [out] -e [colsource] -t [coldest] -p [prefix] -f [suffix] -c [convert] -q [quality] -a [resample] -r [filesrc]"
        echo "mouvRename.sh -b /home/user/rename -s images -d destination -e 1 -t 2 -p Photo_ -f _1 -c 120x120 -q 85 -a 72 -r file.csv"
	echo ""
	echo "-b : répertoire de base sans le / de fin"
	echo "-s : emplacement des fichiers sources à renommer"
	echo "-d : emplacement de destinations des fichiers après renommage"
	echo "-e : numéro de colonne dans le fichier csv contenant le nom du fichier source"
	echo "-t : numéro de colonne dans le fichier csv contenant le nom du fichier de destination"
	echo "-p : prefix à ajouter au nom du fichier de destination"
	echo "-f : suffix à ajouter au nom du fichier de destination"
	echo "-c : active le redimensionnement et la suppression des metadata pour les images."
	echo "     120x120 veut dire que les images seront redimensionnées à 120px de la plus grande dimension"
	echo "     ATTENTION : ne pas activer si vos fichiers ne sont pas des images"
	echo "-q : pourcentage de compression lorsque -c est activée"
	echo "-a : valeur en DPI lorsque -c est activée"
	echo "-r : fichier csv contenant les correspondances entre nom de fichier source et nom de fichier de destination"
	echo ""
	echo "###################################################"
	echo "# /home/user/rename"
	echo "#  |_ images"
	echo "#    |_ fichier1.jpg"
	echo "#    |_ fichier2.jpg"
	echo "#    |_ fichier3.jpg"
	echo "#  |_destination"
	echo "#  file.csv"
	echo "#"
	echo "# --- Structure fichier csv"
	echo "# info;fichier1;autrenom1;photo de vacances"
	echo "# info;fichier2;autrenom2;photo du dimanche"
	echo "# info;fichier3;autrenom3;photo des enfants"
	echo "#"
	echo "# mouvRename.sh -b /home/user/rename -s images -d destination -e 2 -t 3 -p Photo_ -f _1 -c 120x120 -q 85 -a 72 -r file.csv"
	echo "#"
	echo "# --- Résultat"
	echo "# Les images seront redimensionnées au plus grand côté en 120px, en 72 dpi avec un taux de compression à 85% en jpg"
	echo "#"
	echo "# /home/user/rename"
	echo "#  |_ images"
	echo "#  |_ destination"
	echo "#    |_ Photo_autrenom1_1.jpg"
	echo "#    |_ Photo_autrenom2_1.jpg"
	echo "#    |_ Photo_autrenom3_1.jpg"
	echo "#"
	echo "###################################################"
	exit 1
}
if [ -z ${BASE} ]
then
        echo "Le répertoire de base [base] est obligatoire sans les / de fin"
	usage
fi

if [ -z ${DIRSRC} ]
then
        echo "Le répertoire source [source] est obligatoire sans les / de fin"
	usage
fi

if [ -z ${DIROUT} ]
then
        echo "Le répertoire de destination [out] est obligatoire"
	usage
fi
if [ -z ${COLSRC} ]
then
        echo "La colonne source [colsource] est obligatoire"
	usage
fi
if [ -z ${COLDEST} ]
then
        echo "La colonne destination [coldest] est obligatoire"
	usage
fi
if [ -z ${FILESRC} ]
then
        echo "Le fichier source [filesrc] est obligatoire"
	echo "Le fichier source doit se trouver dans la même hiérachie que [base]"
	usage
fi
if [ ! -z ${CONVERT} ]
then
	if [ -z ${QUALITY} ]
	then
		echo "Le taux de compression est obligatoire"
		usage
	fi
	if [ -z ${RESAMPLE} ]
	then
		echo "La valeur de resample est obligatoire"
		usage
	fi
fi

IFS=$'\n'
echo . > "${BASE}/mouvRename.log"
# Parcours du dossier DIRSRC
for FILE in `ls "${BASE}/${DIRSRC}"`
do
	ERREUR=0
	# Extraction du nom du fichier
	FILENAME=`basename "${FILE}" | cut -d"." -f1`
	# Extraction de l'extention du fichier
	FILEEXT=`basename "${FILE}" | cut -d"." -f2`

	echo "Recherche du fichier : ${FILENAME}.${FILEEXT}"
	# Lecture du fichier csv
	while read LINE
	do
		# Extraction de la clé de recherche
		KEY=`echo ${LINE} | cut -d";" -f${COLSRC}`

		# mettre un seul = pour faire une recherche en contient
		# mettre deux = pour faire une recherche exacte
		#if [[ "${FILENAME}" == *"${KEY}"* ]]
		if [[ "${FILENAME}" = "${KEY}" ]]
		then
			echo "Correspondance trouvée : ${KEY} | ${FILENAME}"
			echo "FILENAME = ${FILENAME} | FILEEXT = ${FILEEXT} | COLSRC = ${KEY}" >> "${BASE}/mouvRename.log"

			KEYOUT=`echo ${LINE} | cut -d";" -f${COLDEST}`
			cp -a "${BASE}/${DIRSRC}/${FILENAME}.${FILEEXT}" "${BASE}/${DIROUT}/${KEYOUT/\/_}${SUFFIX}.${FILEEXT}"
			if [ ! -z ${CONVERT} ] 
			then
				convert -sampling-factor 4:2:0 \
					-strip \
					-interlace JPEG \
					-colorspace sRGB \
					-quality ${QUALITY}% \
					-resample ${RESAMPLE} \
					-units PixelsPerInch \
					-resize ${CONVERT} \
					${BASE}/${DIROUT}/${KEYOUT/\/_}${SUFFIX}.${FILEEXT} \
					${BASE}/${DIROUT}/${KEYOUT/\/_}${SUFFIX}.${FILEEXT}
				exiftool -q -all= ${BASE}/${DIROUT}/${KEYOUT/\/_}${SUFFIX}.${FILEEXT}
				exiftool -q -delete_original! ${BASE}/${DIROUT}/${KEYOUT/\/_}${SUFFIX}.${FILEEXT}
			fi

			ERREUR=0
		fi
	done < "${BASE}/${FILESRC}"
	if [ ${ERREUR} == 1 ]
	then
		ERREUR=0
		echo "Pas de correspondance pour le fichier ${FILENAME}.${FILEEXT}" >> "${BASE}/mouvRename-error.log"
	fi
done
