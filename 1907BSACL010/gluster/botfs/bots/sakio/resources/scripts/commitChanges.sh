#!/bin/bash
#echo "UploadFile Test..."
#exit
if [ ! -f /gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt ]
then
	echo ":information_source: No existe una lista de servidores nueva al cual hacer commit!!!"
	exit
fi
mv /gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt /gluster/tmpcommon/sakio/nodelete/checklistservers/servers.txt
if [ "$?" != "0" ]
then
	echo ":x: ERROR: No se pudo realizar el commit de los cambios en la lista de servidores"
	exit
fi
echo ":white_check_mark: Se ha realizado el commit de la nueva lista de servidores. Se ha eliminado la lista anterior"
