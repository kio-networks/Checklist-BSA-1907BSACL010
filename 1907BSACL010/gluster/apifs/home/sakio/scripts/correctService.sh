#!/bin/bash
serveraddr=$1
servicestr=$2
serverlistdir="/gluster/tmpcommon/sakio/nodelete/checklistservers"
localdir=`dirname $0`
if [ -f "${serverlistdir}/servers_new.txt" ]
then
    serverStr=`grep ${serveraddr} ${serverlistdir}/servers_new.txt`
else
    serverStr=`grep ${serveraddr} ${serverlistdir}/servers.txt`
fi
username=`echo $serverStr | cut -d "|" -f 1`
password=`echo $serverStr | cut -d "|" -f 2`
#echo $localdir/correctServiceWin.sh "${serveraddr}" "${username}" "${password}" "${servicestr}"
$localdir/correctServiceWin.sh "${serveraddr}" "${username}" "${password}" "${servicestr}"
