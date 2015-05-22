#!/bin/bash

file="/tmp/artsub.txt"
export_file="/tmp/export_file.csv"
out_file="/tmp/out_file.csv"
line=1
nbline=`wc -l <$file`
i=1

# Transformation du fichier 2 lignes en 1 avec
# séparteur ;
if [ "$1" == "csv" ]
then
	echo "Transformation du fichier en cours, merci de patienter"
	while [ $i -lt $nbline ]
	do
		echo -n "."
		line=$i
	        LIGNE1=`awk 'NR=='"$line"' { print $0 }' $file`

		let "line+=1"
		LIGNE2=`awk 'NR=='"$line"' { print $0 }' $file`

		echo $LIGNE1";"$LIGNE2 >> $export_file

		let "i+=2"
	done
	echo "Fichier $export_file créé"
fi

# Transformation du fichier 1 ligne au format
# csv sur 2 lignes
if [ "$1" == "export" ]
then
	echo "Transformation du fichier, merci de patienter"
	cat $export_file | while read line
	do
		echo -n "."
		VAR1=`echo $line | cut -d ";" -f1`
		VAR2=`echo $line | cut -d ";" -f2`
		VAR3=`echo $line | cut -d ";" -f3`
		VAR4=`echo $line | cut -d ";" -f4`
		VAR5=`echo $line | cut -d ";" -f5`
		VAR6=`echo $line | cut -d ";" -f6`
                VAR7=`echo $line | cut -d ";" -f7`
                VAR8=`echo $line | cut -d ";" -f8`
	
		echo "$VAR1;$VAR2;$VAR3;$VAR4" >> $out_file
		echo "$VAR5;$VAR6;$VAR7;$VAR8" >> $out_file
	done
fi

if [ "$1" == "" ]
then
	echo "Paramètre incorrecte"
	echo "$0 csv : Transforme le fichier $file 2 lignes ligne en 1"
	echo "$0 export : Transforme le fichier $export_file 1 ligne en 2 lignes pour l'importer dans X3"
	exit 1
fi

exit 0
