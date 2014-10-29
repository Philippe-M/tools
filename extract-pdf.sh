#!/bin/bash
if [ $# -eq 0 ];
then
	echo "Il manque le nom du fichier"
	exit 1
else
	ROOT="/home/xxxx/extractPdf"
	outPdf="$ROOT/pdf"
	outText="$ROOT/text"
	outImg="$ROOT/images"

	echo -n "Numéro de la première page : "
	read firstPage
	echo -n "Numéro de la denière page : "
	read lastPage

	echo -n "Masque des fichiers jpg et pdf extrait : "
	read fileNameOut
	
	if [ -z $fileNameOut ];
	then
		echo "Masque de fichier vide"
		exit 1
	else
		echo "+-----------------------+"
		echo "| Extraction des images |"
		pdfimages -f $firstPage -l $lastPage -p  -j $1 $outImg/$fileNameOut

		echo "| Découpage du fichier  |"
		pdfseparate -f $firstPage -l $lastPage $1 $outPdf/$fileNameOut-%d.pdf
		
		echo "| Extraction des textes |"
		echo "+-----------------------+"		
		for FILE in `ls $outPdf`
		do
			pdftotext -raw -nopgbrk $outPdf/$FILE $outText/${FILE%%.*}.txt
			while read ligne
			do
				ligne=`echo $ligne | tr '\r\n' ';'`
				echo -n $ligne >> $outText/$fileNameOut-full.csv
			done < $outText/${FILE%%.*}.txt
			echo "" >> $outText/$fileNameOut-full.csv			
		done		
	fi
fi
exit 0
