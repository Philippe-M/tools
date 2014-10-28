#!/bin/bash
# lit une liste de ligne dans un fichier puis renvoie
# à la ligne en ajoutant un ; toute les x 10 lignes
i=1
for mail in  `cat /home/xxx/fichier-source.csv`
do
        if [ $i -lt 10 ]
        then
                echo -n $mail";" >> /home/xxx/result.csv
                i=$[$i+1]
        else
                echo -e "\n"  >> /home/xxx/result.csv                                                                                                                                                                       
                i=0
        fi
done
