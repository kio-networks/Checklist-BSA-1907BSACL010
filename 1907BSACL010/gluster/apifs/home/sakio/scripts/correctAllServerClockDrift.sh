#!/bin/bash
driftthr="$1"
localdir=`dirname $0`
serverList=`cat ${localdir}/servers.txt`
slackChannel="$3"
maxdrift="$2"
timestamp=`date +"%Y%m%d-%H%M%S.%N"`
statusfile="/gluster/tmpcommon/sakio/driftStatusFiles/drift-status-${timestamp}.tmp"
touch $statusfile
numserver=`wc -l ${localdir}/servers.txt | cut -d " " -f 1`
echo "Querying date & time for ${numserver} servers..."
echo "Max drift allowed: ${driftthr} secs."
echo "Max drift to be auto corrected: ${maxdrift} secs."
for i in $serverList
do
	username=`echo $i | cut -d "|" -f 1`
	password=`echo $i | cut -d "|" -f 2`
	serveraddr=`echo $i | cut -d "|" -f 3`
	#echo "${localdir}/getClockDrift.sh '$username' '$password' '$serveraddr' '${driftthr}' '$statusfile' '$slackChannel' &"
	${localdir}/correctClockDrift.sh "$username" "$password" "$serveraddr" "$driftthr" "$statusfile" "$slackChannel" "$maxdrift" &
	break;
done
