var debug = require('debug')('mod_reporte');

controller.hears(".*checklist.*",['direct_message,direct_mention,mention'], function(bot, message) {
    bot.api.users.info({user: message.user}, (error, response) => {
        let {name, real_name} = response.user;

            bot.reply(message, "Hola "+name+", he recibido tu petición para generar el reporte, espera un momento...");
            var command="ssh -o StrictHostKeyChecking=no api01 '/gluster/apifs/home/sakio/scripts/checkAllServers.sh'";
            try{
                execGetSimpleOutputPromise(command).then(bot.reply(message,"El reporte se está ejecutando... en unos minutos se generará el archivo PDF... Espera por favor..."));
            } catch(e){}
        });
});
