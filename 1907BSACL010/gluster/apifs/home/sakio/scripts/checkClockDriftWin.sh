#!/bin/bash
targetchannel="#botchannel"
#targetchannel="@scastro"
timestamp=`date +"%s.%N"`
localdir=`dirname $0`
username=$1
password=$2
serveraddr=$3
driftthr=$4
logfile=$5
messagedir="/gluster/tmpcommon/sakio/kt-messages"
#statusfile=$5
#channel=$6
#datestr=`psexec.py -debug "${username}":"${password}"@${serveraddr} cmd /c "echo %date%" 2>/dev/null| grep -v "^\[" | grep -v "ErrorCode" | grep -v "^Impacket" | grep -v "pycrypt" | tr -d "\r\b "`
#psexec.py '${username}':'${password}'@${serveraddr} cmd /s /c "echo %date%" 2>/dev/null
#datestr=$( psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c "echo %date%" 2>/dev/null )
#messagefile="/gluster/tmpcommon/sakio/kt-messages/status-${serveraddr}-${timestamp}.txt"
#statmessage="<tr><td>${serveraddr}</td><td>?</td><td>?</td><td>?</td><tr><td>?</td></tr>"
#datestr=`psexec.py "${username}":"${password}"@${serveraddr} cmd /c "echo %date%" 2>/dev/null | grep -e ".*\/.*\/.*" 2>/dev/null | grep -v "^\[" | tr -d "[a-zA-Z]\r\t\b\n "`
#datestr=`psexec.py "${username}":"${password}"@${serveraddr} "powershell.exe get-date -format {yyyy/MM/dd}" 2>/dev/null | grep -e ".*\/.*\/.*" 2>/dev/null | grep -v "^\[" | tr -d "\b\r"`
datestr=`psexec.py "${username}":"${password}"@${serveraddr} -c /gluster/apifs/home/sakio/scripts/getRemoteDate.bat 2>/dev/null | grep -i "[0-9][0-9][0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]" | tr -d "\b\r"`
if [ "$datestr" == "" ]
then
	echo "Could not get remote server date!!!"
        #echo "sendmessage@|${channel}@|x: ERROR: Could not get remote server (${serveraddr}) date (Could NOT connect)!!!" > $messagefile
        #echo "<tr><td>${serveraddr}</td><td>?</td><td>?</td><td>ERROR: Could not get remote server date</td><tr><td>ERROR!!!</td></tr>" >> $statusfile
        exit 1
fi
datelocal=`date +"%Y/%m/%d"`
datestrcl=`echo -e $datestr | grep -v "ErrorCode"`
datemsg=""
if [ "$datestr" != "$datestrcl" ]
then
	echo "Wrong date in remote server (${datestr} != ${datestrcl})!!!"
	#echo "sendmessage@|${channel}@|:x: Wrong date on remote server (${serveraddr}: ${datestrcl})." > $messagefile
	#datemsg=", Date needs correction"
	exit 1
fi
localtime=`date +"%s.%2N"`
timestr=`psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c "echo %time%" 2>/dev/null | tr -d "\b\r\t" | grep -e "^[0-9]*:[0-9]*:[0-9]*\.[0-9]*" 2>/dev/null | grep -v "^\["`
if [ "$?" != "0" ]
then
	echo "Could not get remote server time!!!"
      	#echo ":x: ERROR: Could not get remote server ($serveraddr) time!!!" > $messagefile
	#echo "<tr><td>${serveraddr}</td><td>${datestrcl}</td><td>?</td><td>ERROR: Could not get remote server time</td><tr><td>ERROR!!!</td></tr>" >> $statusfile
      	exit 1
fi
endtime=`date +"%s.%2N"`
timestrcl=`echo -e $timestr | grep -v "ErrorCode" | tr -d "\n"`
remotedatecl=`echo $datestrcl | awk -F "/" '{print($3,"/",$2,"/",$1)}' | tr -d " "`
remotetime=`date +"%s.%2N" -d "$datestrcl $timestrcl" | tr -d "\n"`
drifttime=`echo "$endtime - $remotetime" | bc`
#echo ": $datestrcl : $timestrcl :"
status=""
buttonts=`date +"%s"`
if (( $(echo "( $drifttime * $drifttime ) > ( $driftthr * $driftthr )" |bc -l) )); then
	echo "Clock Drift is more than specified threshold (${drifttime} > ${driftthr} secs.)!!!"
	echo "sendbutton@|${targetchannel}@|Clock Drift Needs Correction on server [${serveraddr}]@|clk/%button_timestamp%/${serveraddr}" >> ${logfile}-buttons
	#echo "sendmessage@|${channel}@|:warning: Clock drift of server ${serveraddr} is more than threshold of $driftthr seconds (${drifttime} secs.)!!!" > $messagefile
	#echo "<tr><td>${serveraddr}</td><td>${datestrcl} ${timestrcl}</td><td>${drifttime}</td><td>INFO: Drift more than threshold of ${driftthr}${datemsg}}</td><tr><td>WARNING!!!</td></tr>" >> $statusfile
	exit 2
else
	echo "Server Date & Time OK!!! (drift: ${drifttime} secs.)"
	#echo "sendmessage@|${channel}@|:white_check_mark: Nothing to do in server ${serveraddr} (drift: ${drifttime} secs.)!!!" > $messagefile
	#echo "<tr><td>${serveraddr}</td><td>${datestrcl} ${timestrcl}</td><td>${drifttime}</td><td>Nothing to do</td><tr><td>OK!!!</td></tr>" >> $statusfile
fi
