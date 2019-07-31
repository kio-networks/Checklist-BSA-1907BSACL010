#!/bin/bash
clockThr="45"
user=$1
password=$2
ip=$3
connType=$4
checks=$5
writefile=$6
logfile=$7
checkhost=$8
scriptDir="/gluster/apifs/home/sakio/scripts"
commTestResult=`${scriptDir}/checkComm.sh ${ip}`
commTestExit="$?"
commClass="OK"
clockClass="OK"
relayClass="OK"
serviceClass="OK"
debugtstamp=`date +"%s.2N"`
debugstr=${debugtstamp}-${ip}
touch ${logfile}-buttons
if [ "$connType" == "ps" ]
then
        serverType="Windows"
elif [ "$connType" == "ssh" ]
then
        serverType="UNIX/Linux"
fi
trap "echo \"<tr><td class='hostname'>${checkhost}</td><td class='ip'>${ip}</td><td class='type'>${serverType}</td><td class='red'> </td><td class='red'> </td>\
      <td class='red'> </td><td class='red'> </td></tr>\" > /gluster/tmpcommon/sakio/healthcheckfiles/${writefile}; echo \"ERROR: Server Check Timeout caused by ${checkhost} (${ip})!!!\" >> $logfile ;exit 124" SIGUSR1 SIGTERM
if [ "$commTestExit" != "0"  ]
then
        echo "<tr><td class='hostname'>${checkhost}</td><td class='ip'>${ip}</td><td class='type'>${serverType}</td><td class='red'> </td><td class='red'> </td>\
              <td class='red'> </td><td class='red'> </td></tr>" > /gluster/tmpcommon/sakio/healthcheckfiles/${writefile}
        echo "ERROR: Communication Failure in host $checkhost" > $logfile
        exit 1
fi
echo "check clock..."
if [ "$connType" == "ps" ]
then
        clockTestResult=`${scriptDir}/checkClockDriftWin.sh $user $password $ip $clockThr $logfile`
        clockTestExit="$?"
elif [ "$connType" == "ssh" ]
then
        clockTestResult=`${scriptDir}/checkClockDriftLin.sh $user $password $ip $clockThr $logfile`
        clockTestExit="$?"
fi
echo "check relay..."
if [[ $checks =~ .*relaycheck.* ]]
then
   IFS=";"
   for i in $checks
   do
      checkname=`echo $i | cut -d ":" -f 1 | tr -d "\n"`
      if [ "$checkname" == "relaycheck" ]
      then
         ips=`echo $i | cut -d ":" -f 2`
         break;
      fi
   done
   unset IFS
   relayTestResult=`${scriptDir}/checkRelay.sh $ips $ip $user $password $logfile`
   relayTestExit="$?"
else
   relayTestResult="Relay test was not required. Skipped."
   relayTestExit="10"
fi
echo "check services..."
if [[ $checks =~ .*servicescheck.* ]]
then
   IFS=";"
   for i in $checks
   do
      checkname=`echo $i | cut -d ":" -f 1 | tr -d "\n"`
      if [ "$checkname" == "servicescheck" ]
      then
         servicenames=`echo $i | cut -d ":" -f 2`
         break;
      fi
   done
   unset IFS
   if [ "$connType" == "ps" ]
   then
      echo "${scriptDir}/checkServicesWin.sh $user $password $ip ${servicenames}"
      servicesTestResult=`${scriptDir}/checkServicesWin.sh $user $password $ip "${servicenames}" $logfile`
      servicesTestExit="$?"
   elif [ "$connType" == "ssh" ]
   then
      servicesTestResult=`${scriptDir}/checkServicesLin.sh $user $password $ip "${servicenames}" $logfile`
      servicesTestExit="$?"
   fi
else
   servicesTestResult="Service check was not required. Skipped."
   servicesTestExit="10"
fi
if [ "$commTestExit" == "0"  ]
then
	commTestColor="'green'"
else
	commTestColor="'red'"
    echo "ERROR: Communication Failure in host $checkhost" >> $logfile
fi
if [ "$clockTestExit" == "0"  ]
then
        clockTestColor="'green'"
else
        clockTestColor="'red'"
	    echo "ERROR: Clock Check on ${ip}: ${clockTestResult}" >> $logfile
	#echo "sendmessage@|#botchannel@|DEBUG INFO: Clock Check on ${ip}: ${clockTestResult}" >/gluster/tmpcommon/sakio/kt-messages/${debugstr}-clock
fi
if [ "$relayTestExit" == "0"  ]
then
        relayTestColor="'green'"
elif [ "$relayTestExit" == "10"  ]
then
	relayTestColor="'yellow'"
else
        relayTestColor="'red'"
	echo "ERROR: Relay Test on ${ip}: ${relayTestResult}" >> $logfile
	#echo "sendmessage@|#botchannel@|DEBUG INFO: Relay Test on ${ip}: ${relayTestResult}" >/gluster/tmpcommon/sakio/kt-messages/${debugstr}-relay
fi
if [ "$servicesTestExit" == "0"  ]
then
        servicesTestColor="'green'"
else
        servicesTestColor="'red'"
        #echo "ERROR: Service Check Failure in host $checkhost" >> $logfile
	#echo "ERROR: Service Status check on ${ip}: ${servicesTestResult}" >> $logfile
	#echo "sendmessage@|#botchannel@|DEBUG INFO: Service check on ${ip}: ${servicesTestResult}" >/gluster/tmpcommon/sakio/kt-messages/${debugstr}-services
fi
#echo -e "<tr><td class='ip'>${ip}</td><td class='type'>${serverType}</td><td class='comm-${commTestExit}' bgcolor=${commTestColor}>${commTestResult}</td><td class='clock-${clockTestExit}' bgcolor=${clockTestColor}><pre>${clockTestResult}</pre></td><td class='relay-${relayTestExit}' bgcolor=${relayTestColor}>${relayTestResult}</td><td class='service-${serviceTestExit}' bgcolor=${servicesTestColor}><pre>${servicesTestResult}</pre></td></tr>" > /gluster/tmpcommon/sakio/healthcheckfiles/${writefile}
echo -e "<tr><td class='hostname'>${checkhost}</td><td class='ip'>${ip}</td><td class='type'>${serverType}</td><td class=${commTestColor}> </td><td class=${clockTestColor}> </td><td class=${relayTestColor}> </td><td class=${servicesTestColor}> </td></tr>" > /gluster/tmpcommon/sakio/healthcheckfiles/${writefile}
