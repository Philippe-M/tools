#!/bin/bash

# +------------------------------------------------
#  Utilise un fichier csv pour rechercher un nom de fichier
#  dans un sous-dossier pour l'ajouter dans une archive zip
# 
#  Un archive zip est créé tout les 100 fichiers
#  Ajout à chaque archive un fichier csv contenant la liste
#  des fichiers
BASE="/home/pmaladjian/Téléchargements/stanley/stafiche"
SRC="FICHESPRODUITS"
SEP=";"
NBFILE=100
I=0
F=0

rm -f ${BASE}/nontrouve.log
rm -f ${BASE}/import.csv

while read LINE
do
	REF=`echo ${LINE} | sed "s/\"//g" | sed "s/${SRC}\///g" | cut -d ${SEP} -f2`
	if [ ! -v ${REF} ]
	then
		SEARCH=`find ${BASE}/${SRC} -name ${REF} -type f -print | wc -l`
		if [ ${SEARCH} -ne 1 ]
		then
			echo "$SEARCH --- Référence $REF - non trouvé" >> ${BASE}/nontrouve.log
		else
			if [ ${I} -le ${NBFILE} ]
			then
				7z a -tzip ${BASE}/import-${F}.zip ${BASE}/${SRC}/${REF}
				echo ${LINE} | sed "s/${SRC}//g" >> ${BASE}/import.csv
				let "I+=1"
			else
				# Ajout de l'entete
				sed -i '1i"sku";"fiche";"fiche_filename"' ${BASE}/import.csv
				7z a -tzip ${BASE}/import-${F}.zip ${BASE}/import.csv

				# re-initialisation des variables pour le 
				# prochain fichier zip
				rm -f ${BASE}/import.csv
				I=0
				let "F+=1"

				7z a -tzip ${BASE}/import-${F}.zip ${BASE}/${SRC}/${REF}
				echo ${LINE} | sed "s/${SRC}//g" >> ${BASE}/import.csv
				let "I+=1"
			fi
		fi	
	fi
done < $BASE"/importsta-fiche.csv"
