#!/bin/bash
ips=$1
relip=$2
srcip=`echo $relip | tr -d "."`
user=$3
password=$4
logfile=$5
tstamp=`date +"%s%N"`
sourcescript="/gluster/apifs/home/sakio/scripts/checkRelayScript.bat"
tmpdir="/gluster/tmpcommon/sakio/relayscripts"
IFS=","
errors=0
for i in $ips
do
	ipaddr=`echo $i | cut -d "/" -f 1`
	sender=`echo $i | cut -d "/" -f 2`
	ip=`echo $ipaddr | tr -d "."`
	scriptname="${tmpdir}/rlchk-${srcip}-${ip}-${tstamp}.bat"
	sed "s/%smtp_server%/${ipaddr}/g" ${sourcescript} > ${scriptname}
    	sed -i "s/%mail_sender%/${sender}/g" ${scriptname}
	rlresult=`psexec.py "${user}":"${password}"@${relip} -c ${scriptname} | grep Email | tr -d "\"\b\r\t"`
	success=`echo $rlresult | grep Successfully | wc -l`
	#echo "$rlresult - $success"
	if [ "$success" == "0"  ]
	then
		echo "ERROR: Could not send relay test mail (Server: ${relip}, Sender: ${sender}, Relay Server: ${ipaddr})<br>"
		echo "ERROR: Relay Test. Could not send relay mail (Server: ${relip}, Sender: ${sender}, Relay Server: ${ipaddr})" >> $logfile
		errors=$(( $errors + 1 ))
		continue	
	fi
	numerrors=`echo $rlresult | grep wrong | wc -l`
	if [ "$numerrors" != "0" ]
	then
		echo "$rlresult <br/>"
		errors=$(( $errors + 1 ))
		continue
	fi
	echo "$rlresult <br/>"
done
unset IFS
if [ "$errors" -gt "0" ]
then
	exit 1
fi
