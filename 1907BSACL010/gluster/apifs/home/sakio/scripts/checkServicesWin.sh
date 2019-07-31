#!/bin/bash
user=$1
pass=$2
ip=$3
checks=$4
logfile=$5
targetChannel="#botchannel"
messagedir="/gluster/tmpcommon/sakio/kt-messages"
errors=0
IFS=","
for i in $checks
do
	sname=`echo $i | cut -d "/" -f 1 | tr -d "\r\n"`
	sstat=`echo $i | cut -d "/" -f 2 | tr -d "\r\n"`
	#echo "psexec.py \"${user}\":\"${pass}\"@${ip} cmd /s /c 'sc query \"${sname}\"'`"
	#echo "$user $pass $ip $sname"
	sinfo=`psexec.py "${user}":"${pass}"@${ip} cmd /s /c sc query \"${sname}\" | tr -d "\r\b\t"`
	#echo "$sinfo"
	sok=`echo -e "$sinfo" | tr -d "\r\t\b" | grep "SERVICE_NAME:" | wc -l`
	if [ "$sok" == "0" ]
	then
		echo "ERROR: Service Check Failure (${ip}): Could not get service info (${sname} in ${ip})!!!"
		echo "ERROR: Service Check Failure: Could not check service status (${ip}/${sname}/${sstat})" >> $logfile
		errors=$(( $errors + 1 ))
		continue
	fi
	isrunning=`echo -e "$sinfo" | grep "RUNNING" | wc -l`
	if [ "$isrunning" == 0 ]
	then
		status="down"
	elif [ "$isrunning" == 1 ]
	then
		status="up"
	else
		echo "ERROR: Service check Failure: Could not check service status (${ip}/${sname}/${sstat})" >> $logfile
		errors=$(( $errors + 1 ))
		continue
	fi
	#echo "Service ${sname} is ${status}, should be ${sstat}..."
	if [ "$sstat" == "$status" ]
	then
		echo "Service (${sname}) state in $ip is OK (Service is ${status})" > /dev/null
	else
        tstamp=`date +%s`
		echo "ERROR: Service Check Status: (${ip}) is NOT OK (Service ${sname } is ${status}, should be ${sstat})" >> $logfile
        	echo "sendbutton@|@${targetChannel}@|Service Status Needs Correction [${ip}/${sname}/${sstat}]@|svc/%button_timestamp%/${ip}/${sname}/${sstat}" >> ${logfile}-buttons
		errors=$(( $errors + 1 ))
		continue
	fi
done
unset IFS
if [ "$errors" != "0" ]
then
	echo "ERROR: Service Status (${ip}). Found $errors service errors in $ip!!!"
	exit 1
fi
