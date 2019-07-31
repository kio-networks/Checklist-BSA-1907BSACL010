#!/bin/bash
#echo "UploadFile Test..."
#exit
#rm /gluster/tmpcommon/sapunix/opciones/nodelete/metadata.js
if [ ! -f /gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt ]
then
	echo ":information_source: No existe una lista de servidores a la cual hacer rollback!!!"
	exit
fi
rm -f /gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt
if [ "$?" != "0" ]
then
	echo ":x: ERROR: No se pudo realizar el commit de los cambios en la lista de servidores"
	exit
fi
echo ":white_check_mark: Rollback realizado exitosamente. Se ha resturado la lista de servidores anterior"
