#!/bin/bash
export PATH="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/bin"

##  Initialize Script Variables  ####################################################

sysLog=/var/log/messages
sysTmp=/tmp/syslogtemp

json=/storage/www/html/syslog.json
jsonTmp=/tmp/syslogbashtemp

logDuration=60

########################################################################################

currentTime=$(date "+%g%m%d%H%M")
host=`hostname`

echo -e "{\n\"syslog\":\n\t{" > $jsonTmp

echo -e "\t\"hostName\": \"$host\"," >> $jsonTmp
echo -e "\t\"queryTime\": \"$currentTime\"," >> $jsonTmp
echo -e "\t\"systemLog\":[" >> $jsonTmp

tac $sysLog > $sysTmp
countLines=`tac $sysTmp | wc -l`
i=0
while read -r line; do
	i=$[$i+1]
        timeStamp=`echo $line | cut -f1-3 -d" "`
	hostName=`echo $line | cut -f4 -d" "`
        source=`echo $line | cut -f5 -d" "`
        message=`echo $line | cut -f6-99 -d" " | sed "s/\"/'/g"`

	echo -e "\t{" >> $jsonTmp
	echo -e "\t\t\"timeStamp\":\"$timeStamp\"," >> $jsonTmp
        echo -e "\t\t\"hostName\":\"$hostName\"," >> $jsonTmp
        echo -e "\t\t\"source\":\"${source%?}\"," >> $jsonTmp
        echo -e "\t\t\"message\":\"$message\"" >> $jsonTmp
	if [ $i -lt $countLines ]; then
	        echo -e	"\t},"  >> $jsonTmp
	else 
		echo -e	"\t}"  >> $jsonTmp
	fi
done  < "$sysTmp"
echo "]}}" >> $jsonTmp
cp $jsonTmp $json

rm $jsonTmp
rm $sysTmp



