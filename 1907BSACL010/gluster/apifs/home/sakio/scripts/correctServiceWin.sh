#/bin/bash
serveraddr=$1
username=$2
password=$3
servicestr=$4
sname=`echo $servicestr | cut -d "/" -f 1 | tr -d "\r\n"`
sstat=`echo $servicestr | cut -d "/" -f 2 | tr -d "\r\n"`
#echo psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c sc query \"${sname}\"
sinfo=`psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c sc query \"${sname}\"`
if [ "$?" != "0" ]
then
    echo ":x: EROOR: Could not retrieve service status [${servicestr}]"
    exit
fi
sinfo=`psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c sc query \"${sname}\" | tr -d "\b\t\r" | grep STATE`
up=`echo $sinfo | grep "RUNNING" | wc -l`
down=`echo $sinfo | grep "STOPPED" | wc -l`
#echo "$sinfo ; $up ; $down"
if [ "$up" != "0" ] && [ "$sstat" == "up" ]
then
    echo ":information_source: :heavy_check_mark: Actual status of service is equal to desired state [${serveraddr}/${servicestr}]"
    exit
elif [ "$down" != "0" ] && [ "$sstat" == "down" ]
then
    echo ":information_source: :heavy_check_mark: Actual status of service is equal to desired state [${serveraddr}/${servicestr}]"
    exit
fi
if [ "$sstat" == "up" ]
then
    psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c sc start \"${sname}\" > /dev/null 2>&1
elif [ $sstat == "down" ]
then
    psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c sc stop \"${sname}\" > /dev/null 2>&1
fi
sleep 10
sinfo=`psexec.py "${username}":"${password}"@${serveraddr} cmd /s /c sc query \"${sname}\" | tr -d "\b\t\r" | grep STATE`
up=`echo $sinfo | grep "RUNNING" | wc -l`
down=`echo $sinfo | grep "STOPPED" | wc -l`
if [ "$up" != "0" ] && [ "$sstat" == "up" ]
then
    echo ":heavy_check_mark: Status of service was succesfully corrected to desired state [${serveraddr}/${servicestr}]"
    exit
elif [ "$down" != "0" ] && [ "$sstat" == "down" ]
then
    echo ":heavy_check_mark: Status of service was succesfully corrected to desired state [${serveraddr}/${servicestr}]"
    exit
else
    echo ":x: ERROR: Service status could not be corrected to desired state [${serveraddr}/${servicestr}]"
fi
