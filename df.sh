#!/bin/bash
export PATH="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/bin"

##### CONFIG ##############

json=/storage/www/html/df.json
jsonTemp=/tmp/dfjsontemp

###########################
currentTime=$(date "+%g%m%d%H%M")
host=`hostname`

dfInfo=`df` 

echo -e "{\n\"df\":\n\t{" > $jsonTemp

echo -e "\t\"hostName\": \"$host\"," >> $jsonTemp
echo -e "\t\"queryTime\": \"$currentTime\"," >> $jsonTemp
echo -e "\t\"diskFree\":[" >> $jsonTemp
 
countFS=`df | wc -l`

i=0
while read -r line; do
        if [[ $i -eq 0 ]]; then
		i=$[$i +1]
	else
		i=$[$i +1]
		for n in {1..6}; do
			field[$n]=`echo $line | cut -f$n -d" "`
		done
		echo -e "\t{" >> $jsonTemp
		echo -e "\t\t\"filesystem\":\"${field[1]}\"," >> $jsonTemp
	        echo -e "\t\t\"1kBlocks\":\"${field[2]}\"," >> $jsonTemp
	        echo -e "\t\t\"used\":\"${field[3]}\"," >> $jsonTemp
	        echo -e "\t\t\"available\":\"${field[4]}\"," >> $jsonTemp
	        echo -e "\t\t\"usedPerc\":\"${field[5]}\"," >> $jsonTemp
	        echo -e "\t\t\"mountedOn\":\"${field[6]}\"" >> $jsonTemp
		if [ $i -lt $countFS ]; then
		        echo -e	"\t},"  >> $jsonTemp
		else 
			echo -e	"\t}"  >> $jsonTemp
		fi
	fi
done  <<< "$dfInfo"

echo "]}}" >> $jsonTemp

cp $jsonTemp $json
rm $jsonTemp
