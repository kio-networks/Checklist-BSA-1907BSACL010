#!/bin/bash
server="$1"
driftthr="40"
localdir=`dirname $0`
serverlistdir="/gluster/tmpcommon/sakio/nodelete/checklistservers"
if [ -f "${serverlistdir}/servers_new.txt" ]
then
    serverStr=`grep ${server} ${serverlistdir}/servers_new.txt`
else
    serverStr=`grep ${server} ${serverlistdir}/servers.txt`
fi
statusfile="/gluster/tmpcommon/sakio/dummy.txt"
slackChannel="#botchannel"
maxdrift="5"
timestamp=`date +"%Y%m%d-%H%M%S.%N"`
#echo "Querying date & time for ${server} servers..."
#echo "Max drift allowed: ${driftthr} secs."
#echo "Max drift to be auto corrected: ${maxdrift} secs."
username=`echo $serverStr | cut -d "|" -f 1`
password=`echo $serverStr | cut -d "|" -f 2`
#serveraddr=`echo $serverStr | cut -d "|" -f 4`
#echo ${localdir}/correctClockDrift.sh "$username" "$password" "$serveraddr" "$driftthr" "$statusfile" "$slackChannel" "$maxdrift"
${localdir}/correctClockDrift.sh "$username" "$password" "$server" "$driftthr" "$statusfile" "$slackChannel" "$maxdrift"
