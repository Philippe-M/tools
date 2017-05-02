#!/bin/bash
# lit une liste de ligne dans un fichier puis renvoie
# à la ligne en ajoutant un ; toute les x lignes

if [ "i${1}" == "" ]
then
	echo "Fichier ou chemin d'accès invalide"
	echo "{$1}"

	exit 1
else
	DIROUT="${HOME}/Scripts/tools"
	FICOUT=`basename "${1}"`
	NBLIG=10

	i=1
	for mail in  `cat "${1}"`
	do
        	if [ $i -lt "${NBLIG}" ]
	        then	
        	        echo -n $mail";" >> "${DIROUT}"/"new-${FICOUT}"
                	i=$[$i+1]
	        else
        	        echo -e "\n"  >> "${DIROUT}"/"new-${FICOUT}"
                	i=0
	        fi
	done
fi

exit 0
