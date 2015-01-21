#!/bin/bash
i=1
for mail in `cat /home/xxx/Bureau/gedimat.csv`
do
	if [ $i -lt 10 ]
	then
		echo -n $mail";" >> /home/xxx/Bureau/result.csv
		i=$[$i+1]
	else
		echo -e "\n"  >> /home/xxx/Bureau/result.csv
		i=0
	fi
done
