#!/bin/bash
export PATH="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/bin"

##  Initialize Script Variables  ####################################################

logFile=/storage/logs/server-vmstat.log
logTemp=/tmp/vmstattemp

json=/storage/www/html/vmstat.json
jsonTemp=/tmp/vmstatjsontmp

logDuration=60

########################################################################################

currentTime=$(date "+%g%m%d%H%M")
host=`hostname`

echo -e "{\n\"vmstat\":\n\t{" > $jsonTemp

echo -e "\t\"hostName\": \"$host\"," >> $jsonTemp
echo -e "\t\"queryTime\": \"$currentTime\"," >> $jsonTemp
echo -e "\t\"virtualMemoryStat\":[" >> $jsonTemp

line=`vmstat | cut -d$'\n' -f3`
line="$currentTime $line"

for n in {1..18}; do
	field[$n]=`echo $line | cut -f$n -d" "`
done

echo -e "\t{" > $logTemp
echo -e "\t\t\"timeStamp\":\"${field[1]}\"," >> $logTemp
echo -e "\t\t\"r\":\"${field[2]}\"," >> $logTemp
echo -e "\t\t\"b\":\"${field[3]}\"," >> $logTemp
echo -e "\t\t\"swpd\":\"${field[4]}\"," >> $logTemp
echo -e "\t\t\"free\":\"${field[5]}\"," >> $logTemp
echo -e "\t\t\"buff\":\"${field[6]}\"," >> $logTemp
echo -e "\t\t\"cache\":\"${field[7]}\"," >> $logTemp
echo -e "\t\t\"si\":\"${field[8]}\"," >> $logTemp
echo -e "\t\t\"so\":\"${field[9]}\"," >> $logTemp
echo -e "\t\t\"bi\":\"${field[10]}\"," >> $logTemp
echo -e "\t\t\"bo\":\"${field[11]}\"," >> $logTemp
echo -e "\t\t\"in\":\"${field[12]}\"," >> $logTemp
echo -e "\t\t\"cs\":\"${field[13]}\"," >> $logTemp
echo -e "\t\t\"us\":\"${field[14]}\"," >> $logTemp
echo -e "\t\t\"sy\":\"${field[15]}\"," >> $logTemp
echo -e "\t\t\"id\":\"${field[16]}\"," >> $logTemp
echo -e "\t\t\"wa\":\"${field[17]}\"," >> $logTemp
echo -e "\t\t\"st\":\"${field[18]}\"" >> $logTemp
echo -e "\t},"  >> $logTemp


cat $logFile >> $logTemp 2>/dev/null
sed -i '$s/,$//' $logTemp

head -n+$[logDuration*20] $logTemp > $logFile
cat $logFile >> $jsonTemp 2>/dev/null


echo "]}}" >> $jsonTemp

cp $jsonTemp $json

rm $jsonTemp
rm $logTemp

