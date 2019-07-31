var debug = require('debug')('mod_receivefile');

var fs = require('fs'); // write/read file on server
var request = require('request');
// Listen to user's message
controller.on('file_share', function(bot, message) {
  // Check for an attachment
  debug(message);
  if(message.channel_type != "channel"){
      debug("File not sent in a group channel... Ignoring: "+message.files[0].name);
      return;
  }
  if(message.channel != "CFPDETKC3"){
      debug("File not sent in admin channel... Ignoring: "+message.files[0].name);
      return;
  }
  if(message.files[0].filetype != "text"){
      bot.reply(message,"Se recibió un archivo que no es de tipo texto ("+message.files[0].name+"). Ignorando archivo.");
      return;
  }
  if(message.files[0].name != "servers_new.txt"){
      bot.reply(message,"Sólo puedo procesar archivos con el nombre 'servers_new.txt' (todo en minúsculas). Ignorando archivo ("+message.files[0].name+").");
      return;
  }
  if (fs.existsSync('/gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt')) {
      console.error('myfile already exists');
      bot.reply(message,":warning: :bangbang: Existe un respaldo de la lista de servidores anterior.\nEsto significa que se ha actualizado anteriormente el archivo, pero no se ha hecho un commit o un rollback del mismo, lo cual es necesario para poder actualizar nuevamente.\nPara hacer commit, envía por este canal el mensaje 'server-list commit',\nPara hacer un rollback, envía por este canal el mensaje 'server-list rollback'.\nUna vez realizado el commit o el rollback, se podrá actualizar nuevamente la lista de servidores.");
      return;
    }
  else {
    bot.reply(message,"Se ha descargado la nueva lista de servidores.\nEste nuevo archivo se utilizará para realizar los checklist que se soliciten a partir de este momento.\nNo olvide realizar el commit (server-list commit) para hacer permanente el cambio, o un rollback (server-list rollback) para volver a la versión anterior. Si no se realiza alguna de estas acciones, no será posible actualizar nuevamente el archivo.");
    downloadFile("/gluster/tmpcommon/sakio/nodelete/checklistservers/servers_new.txt",message.files[0].url_private);
  }
  /*execGetSimpleOutputPromise("/gluster/botfs/bots/sapunix/resources/scripts/updateOptionsTree.sh").then(function(value){
            bot.reply(message,value);
            if(value.search("No se ha podido realizar el rollback") == -1){
                //debug("OK!!!");
                parser=require('/gluster/botfs/bots/sapunix/bot_modules/parseo.js');
                parser.readMenuTXT();
            }
        });*/
});
  //parser=require('/gluster/botfs/bots/sapunix/bot_modules/parseo.js');

controller.hears(['server-list commit'], 'direct_message,direct_mention', function(bot,message){
    if(message.channel != "CFPDETKC3"){
      debug("File not sent in admin channel... Ignoring: "+message.files[0].name);
      return;
    }
    execGetSimpleOutputPromise("/gluster/botfs/bots/sakio/resources/scripts/commitChanges.sh").then(function(value){
        bot.reply(message,value);
    });
});


controller.hears(['server-list rollback'], 'direct_message,direct_mention', function(bot,message){
   if(message.channel != "CFPDETKC3"){
      debug("File not sent in admin channel... Ignoring: "+message.files[0].name);
      return;
    }
    execGetSimpleOutputPromise("/gluster/botfs/bots/sakio/resources/scripts/rollbackChanges.sh").then(function(value){
        bot.reply(message,value);
    });
});

downloadFile = function(destination,url){
    console.log("RETRIEVING FILE...");
    var opts = {
		method: 'GET',
		url: url,
		headers: {
		  Authorization: 'Bearer ' + token, // Authorization header with bot's access token
		}
	};
    request(opts, function(err, res, body) {
		// body contains the content
		console.log('FILE RETRIEVE STATUS',res.statusCode);
	}).pipe(fs.createWriteStream(destination)); // pipe output to filesystem
}
