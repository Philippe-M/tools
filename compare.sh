#!/bin/bash

# Lit une liste de références ou gencod et
# recherche si une photo est trouvé avec ce nom

SRC="/src"
SEP=";"

while read LINE
do
	REF=`echo ${LINE} | cut -d $SEP -f1`
	EAN=`echo ${LINE} | cut -d $SEP -f2`

	SEARCH=`find ${SRC}/export/ -iname ${EAN}* -type f -print | wc -l`
	if [ ${SEARCH} -ne 1 ]
	then
		echo "$SEARCH --- Référence $REF - $EAN non trouvé" >> ${SRC}/nontrouve.log
	fi
done < $SRC"/fic.csv"
