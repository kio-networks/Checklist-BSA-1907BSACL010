#!/bin/bash
maxiter="10"
localdir=`dirname $0`
username=$1
password=$2
serveraddr=$3
driftthr=$4
statusfile=$5
channel=$6
maxdrift=$7
timestamp=`date +"%s.%N"`
messagefile="/gluster/tmpcommon/sakio/kt-messages/status-${serveraddr}-${timestamp}.txt"
statmessage="<tr><td>${serveraddr}</td><td>?</td><td>?</td><td>?</td><tr><td>?</td></tr>"
#datemsg=":information_source: Checking timedate on ${serveraddr}...\n"
datestr=`psexec.py "${username}":"${password}"@${serveraddr} -c /gluster/apifs/home/sakio/scripts/getRemoteDate.bat 2>/dev/null`
if [ "$?" != "0" ]
then
	datemsg=":x: ERROR: Could not get date on server ${serveraddr}!!!"
	#echo "sendmessage@|${channel}@|x: ERROR: Could not get remote server (${serveraddr}) date!!!" > $messagefile
	#echo "<tr><td>${serveraddr}</td><td>?</td><td>?</td><td>ERROR: Could not get remote server date</td><tr><td>ERROR!!!</td></tr>" >> $statusfile
	echo $datemsg
	exit
fi
datelocal=`date +"%Y/%m/%d"`
datestr=`psexec.py "${username}":"${password}"@${serveraddr} -c /gluster/apifs/home/sakio/scripts/getRemoteDate.bat 2>/dev/null | grep -e "[0-9][0-9][0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]" | tr -d "\r\b "`
datestrcl="$datestr"
if [ "$datestr" != "$datelocal" ]
then
	#echo "sendmessage@|${channel}@|:x: Wrong date on remote server (${serveraddr}: ${datestrcl})." > $messagefile
	datemsg=":x: ERROR: Server Date needs correction on server ${serveraddr}. Aborting time correction!!!\n"
	echo $datemsg
	exit
fi
localtime=`date +"%s.%2N"`
timestr=`psexec.py "${username}":"${password}"@${serveraddr} cmd /c "echo %time%" 2>/dev/null`
if [ "$?" != "0" ]
then
	datemsg=":x: ERROR: Could not get current time on server ${serveraddr}!!!"
      	#echo ":x: ERROR: Could not get remote server ($serveraddr) time!!!" > $messagefile
	#echo "<tr><td>${serveraddr}</td><td>${datestrcl}</td><td>?</td><td>ERROR: Could not get remote server time</td><tr><td>ERROR!!!</td></tr>" >> $statusfile
	echo $datemsg
      	exit
fi
timestr=`psexec.py "${username}":"${password}"@${serveraddr} cmd /c "echo %time%" 2>/dev/null | grep -e "[0-9]*:[0-9]*:[0-9]*\.[0-9]*" 2>/dev/null | grep -v "^\[" | tr -d "\r\t\b\n "`
endtime=`date +"%s.%2N"`
timestrcl="$timestr"
remotedatecl=`echo $datestrcl | awk -F "/" '{print($3,"/",$2,"/",$1)}' | tr -d " "`
remotetime=`date +"%s.%2N" -d "$datestr $timestrcl"`
drifttime=`echo "$endtime - $remotetime" | bc`
curriter="0"
currdrift="0"
if (( $(echo "( $drifttime * $drifttime ) > ( $driftthr * $driftthr )" |bc -l) )); then
	olddrift=$drifttime
	#datemsg="${datemsg}:warning: Server time needs correction (drift: ${drifttime} secs.)\n:watch: Trying to correct...\n"
	#echo "sendmessage@|${channel}@|:warning: Clock drift of server ${serveraddr} is more than threshold of $driftthr seconds (${drifttime} secs.)... Trying to correct...!!!" > ${messagefile}.2
	while : ; do
		newtime=`date +"%s.%2N"`
		newtime=`echo "scale=0; (${newtime} + ${currdrift}) / 1" | bc`
		wintime=`date -d "@${newtime}" +"%I:%M:%S %p"`
		timecorrect=`psexec.py "${username}":"${password}"@${serveraddr} cmd /c "time $wintime" 2>/dev/null`
		if [ "$?" != "0"  ]
		then
			#echo "sendmessage@|${channel}@|:x: Clock drift of server ${serveraddr} (${olddrift} secs.) could NOT be corrected!!!" > ${messagefile}.2
			datemsg=":x: ERROR: Could not change time on server ${serveraddr}!!!"
			echo $datemsg
			exit
		fi
		timestr=`psexec.py "${username}":"${password}"@${serveraddr} cmd /c "echo %time%" 2>/dev/null | grep -e "[0-9]*:[0-9]*:[0-9]*\.[0-9]*" 2>/dev/null | grep -v "^\[" | tr -d "\r\t\b\n "`
		endtime=`date +"%s.%2N"`
		timestrcl=`echo -e $timestr | grep -v "ErrorCode"`
		datestr=`psexec.py "${username}":"${password}"@${serveraddr} -c /gluster/apifs/home/sakio/scripts/getRemoteDate.bat 2>/dev/null | grep -e "[0-9][0-9][0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]" | tr -d "\r\b "`
		datestrcl=`echo -e $datestr | grep -v "ErrorCode"`
		#remotedatecl=`echo $datestrcl | awk -F "/" '{print($3,"/",$2,"/",$1)}' | tr -d " "`
		remotetime=`date +"%s.%2N" -d "$datestr $timestrcl"`
		drifttime=`echo "$endtime - $remotetime" | bc`
		currdrift="$drifttime"
		absdrift=`echo $currdrift | tr -d "-"`
		curriter=$(( $curriter + 1 ))
		if (( $(echo "( $drifttime * $drifttime ) < ( $maxdrift * $maxdrift )" |bc -l) ))
		then
			#echo "sendmessage@|${channel}@|:information_source: Clock drift of server ${serveraddr} was corrected (from ${olddrift} to 0${absdrift} secs.)" > ${messagefile}.corrected
			#echo "<tr><td>${serveraddr}</td><td>${datestrcl} ${timestrcl}</td><td>${drifttime}</td><td>INFO: Drift corrected (from ${olddrift} secs.}</td><tr><td>OK!!!</td></tr>" >> ${statusfile}
			datemsg=":heavy_check_mark: Clock Drift Successfully corrected on server ${serveraddr}!!!"
			echo $datemsg
			break;
		fi
		if [ "$curriter" -gt "$maxiter"  ]
		then
			datemsg=":warning: Could not lower drift below ${maxdrift} secs. in server ${serveraddr}!!!"
			echo $datemsg/datemsg

			#echo ":warning: Could not lower drift more than 1 second" > ${messagefile}.couldnotcorrect
			#echo "<tr><td>${serveraddr}</td><td>${datestrcl} ${timestrcl}</td><td>${drifttime}</td><td>INFO: Drift corrected (from ${olddrift} secs.}</td><tr><td>OK!!!</td></tr>" >> ${statusfile}
			break;
		fi
	done
else
	datemsg=":information_source: :heavy_check_mark: Clock drift is below threshold in server ${serveraddr}. Not taking any action!!!"
	echo $datemsg
	#echo "sendmessage@|${channel}@|:white_check_mark: Nothing to do in server ${serveraddr} (drift: ${drifttime} secs.)!!!" > $messagefile
	#echo "<tr><td>${serveraddr}</td><td>${datestrcl} ${timestrcl}</td><td>${drifttime}</td><td>Nothing to do</td><tr><td>OK!!!</td></tr>" >> $statusfile
fi
