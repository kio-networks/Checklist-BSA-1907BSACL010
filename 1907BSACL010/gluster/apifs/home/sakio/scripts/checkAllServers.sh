#!/bin/bash
actualdir=`dirname $0`
reqid=`date +"%Y%m%d-%H%M%S.%N"`
PIDS=""
serverid="001";
servernum=1
outputfile="/gluster/tmpcommon/sakio/healthcheckfiles/report-${reqid}.html"
pdffile="/gluster/tmpcommon/sakio/healthcheckfiles/report-${reqid}.pdf"
detailsfilename="/gluster/tmpcommon/sakio/healthcheckfiles/report-details-$reqid.log"
messagedir="/gluster/tmpcommon/sakio/kt-messages"
touch $detailsfilename
IFS=$'\n'
serverlistfile="/gluster/tmpcommon/sakio/nodelete/checklistservers/servers.txt"
if [ -f "/gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt" ]
then
	serverlistfile="/gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt"
fi
#for i in `cat $actualdir/servers.txt`
for i in `cat ${serverlistfile}`
do
	#echo "checking $i..."
	fileid="${reqid}.${serverid}.txt"
	user=`echo $i | cut -d "|" -f 1`
	password=`echo $i | cut -d "|" -f 2`
	checkhost=`echo $i | cut -d "|" -f 3`
	ip=`echo $i | cut -d "|" -f 4`
	connType=`echo $i | cut -d "|" -f 5`
	checks=`echo $i | cut -d "|" -f 6`
	#echo "${actualdir}/checkServer.sh '$user' '$password' '$ip' '$connType' '$checks' '$fileid'"
	#echo "--> ${actualdir}/checkServer.sh $user $password $ip $connType $checks $fileid $detailsfilename $checkhost <--"
	#continue
	nohup timeout -s SIGUSR1 300 ${actualdir}/checkServer.sh "$user" "$password" "$ip" "$connType" "$checks" "$fileid" "$detailsfilename" "$checkhost" &>/dev/null &
    PIDS+=($!)
    HOSTS+=($checkhost)
	servernum=$(( $servernum + 1 ))
	if [ "$servernum" -lt 10  ]
	then
		serverid="00${servernum}"
	elif [ "$servernum" -ge 10 ] && [ "$servernum" -lt 100 ]
	then
		serverid="0${servernum}"
	else
		serverid=$servernum
	fi
done
unset IFS
#exit
iter="0"
while :
do
	sleep 3
	nprocs=`ps -eaf | grep ${reqid} | grep -v grep | wc -l`
	#echo "Waiting $nprocs thread(s) to end..."
	if [ "$nprocs" == 0 ]
	then
		break;
	else
		iter=$(( $iter + 1 ))
	fi
	if [ "$iter" -ge "200" ]
	then
		break
	fi
done
titledate=`date +"%d/%m/%y - %H:%M"`
echo "<html><head><link rel='stylesheet' href='/gluster/apifs/home/sakio/styles/style.css'></head><body><table border='1px solid black;' width='100%' class='reporte'>" > $outputfile
echo "</div><img align='left' src='/gluster/apifs/home/sakio/images/sa.png'><img align='right' src='/gluster/apifs/home/sakio/images/kio.png'><br><br><div align='center' id='Titulo'> Check List Report ${titledate}</div><br><br>" >> $outputfile
echo "<tr class='header'><th>Hostname</th><th class='header'>IP</th><th class='header'>OS</th><th class='header'>Communication Test</th><th class='header'>Clock Drift Test</th><th class='header'>Mail Relay Test</th><th class='header'>Service Check</th></tr>" >> $outputfile
cd /gluster/tmpcommon/sakio/healthcheckfiles/
cat `ls *${reqid}*.txt | sort` >> $outputfile
echo "</table><br><br><pre><strong>Detalles del reporte:</strong>" >> $outputfile
echo "<pre>" >> $outputfile
echo "<strong>Clock Check Errors:</strong>" >> $outputfile
grep "ERROR: Clock Check" $detailsfilename | sort >> $outputfile
echo "<br><strong>Relay Test Errors:</strong>" >> $outputfile
grep "ERROR: Relay Test" $detailsfilename | sort >> $outputfile
echo "<br><strong>Services Test Errors:</strong>" >> $outputfile
grep "ERROR: Service Check" $detailsfilename | sort >> $outputfile
echo "<br><strong>Server Check Timeout Errors:</strong>" >> $outputfile
grep "ERROR: Server Check Timeout" $detailsfilename | sort >> $outputfile
#cat $detailsfilename >> $outputfile
echo "</pre></body></html>" >> $outputfile
/gluster/apifs/API/common_api/scripts/html2pdf.sh --margin-bottom 0.0 --margin-top 0.0 -s Legal -O landscape --title Reporte_HealthCheck $outputfile $pdffile > /dev/null 2>&1
echo "uploadfile@|#botchannel@|${pdffile}@|Reporte de Healtcheck TS: ${reqid}" > /gluster/tmpcommon/sakio/kt-messages/pdf-report-${reqid}
sleep 5
buttonN=1
buttonTstamp=`date +"%s.%4N"`
buttonts=`date +"%s"`
sed -i "s/%button_timestamp%/${buttonts}/g" ${detailsfilename}-buttons
IFS=$'\n'
for i in `cat ${detailsfilename}-buttons`
do
    echo "$i" > ${messagedir}/button-${buttonTstamp}-${buttonN}
    buttonN=$(( $buttonN + 1 ))
done
unset IFS
#rm *${reqid}*.txt
