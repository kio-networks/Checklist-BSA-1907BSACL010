#!/bin/bash
serveraddr=$1
ping -c 4 $serveraddr &>/dev/null
if [ "$?" != "0"  ]
then
	#echo "Packet loss while pinging server!!!"
	exit 1
fi
echo "Communication with server OK!!!"
