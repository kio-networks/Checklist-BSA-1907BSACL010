var debug = require('debug')('mod_watchmessages');
var maxButtonLifetimeSecs = 600;

function botTalk(user,message){
    return;
	const exec = require('child_process').exec;
    console.log("---------------- DEBUG: Send user:message -> "+bot_path+" "+user+" "+message);
	var talkscript = exec(bot_path+'/scripts/sendFCM.sh '+user+' "'+message+'"',
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                //console.log(`exec error: ${error}`);
                //console.log(`\nprocessing done...\n\nｻ ｹ ｿ ﾄ ﾂ ｿ ｾ  -  (KIOtron)\nC O R E  -  R E A D Y . . .`);
            }
        });
}
enableMessagesIPC=true;
deleteAllFiles('/gluster/tmpcommon/sakio/kt-messages');
if(enableMessagesIPC){
    fsMonitor = require('chokidar');
    console.log("Watching messages!!!!!!!");
    /*fsMonitor.watch("/gluster/tmpcommon/datamgmt/kt-messages", { persistent: true,usePolling: true, interval: 1000 }, function (event, fileName) {
        console.log("Event: " + event);
        console.log(fileName + "\n");
    });*/
    fsMonitor.watch('/gluster/tmpcommon/sakio/kt-messages', {persistent:true,usePolling:true,interval:500,awaitWriteFinish:true}).on('add', (path) => {
        //console.log(path);
        processFile(path);
    });
}
// File message format:
// sendmessage@|channel@|message
// uploadfile
function processFile(path){
    console.log(path);
    var fs = require('fs'),
    readline = require('readline');
    var finalMessage="";
    var sendChannel="";
    var userName=""
    var rd = readline.createInterface({
        input: fs.createReadStream(path),
        output: process.stdout,
        console: false
    });
    rd.on('line', function(line) {
        linea=line.split("@|");
        if (linea.length == 1){
            finalMessage+=line+"\n";
            //triggerMessage(defaultAdminChannel,line)
        }
        if(linea[0].toLowerCase() == "sendmessage"){
            triggerMessage(linea[1],linea[2]);
        }
        else if (linea[0].toLowerCase() == "uploadfile") {
            fileupload(linea[1],linea[2],linea[3]);
        }
        else if (linea[0].toLowerCase() == "sendbutton") {
            triggerButtonMessage(linea[1],linea[2],linea[3]);
        }
    });
    rd.on('close',function() {
        if(finalMessage != ""){
            triggerMessage(sendChannel,finalMessage)
        }
        fs.unlink(path, err => {
            if (err) console.log("Message Watcher WARNING: Could not delete file "+file+"("+err+")...");
        });
        console.log("Processed and deleted file: "+path);
    });
}

function deleteAllFiles(delpath){
    const fs = require('fs');
    const pathutil = require('path');
    const directory = delpath;
    console.log("Message Watcher INFO: Deleting all existing files in "+delpath+" ...");
    fs.readdir(directory, (err, files) => {
        if (err) throw err;
        for (const file of files) {
            fs.unlink(pathutil.join(directory, file), err => {
                if (err) console.log("Message Watcher WARNING: Could not delete file "+file+"("+err+")...");
            });
        }
    });
}

function triggerButtonMessage(channel,message,actionstr){
    var actions = actionstr.split("/");
    var actionmessage=""
    if(actions[0]=="clk"){
	actionmessage="["+actions[2]+"]: Corregir el drift del reloj en este servidor?"
    }
    if(actions[0]=="svc"){
	actionmessage="["+actions[2]+"/"+actions[3]+"/"+actions[4]+"]: Corregir el estado del servicio en este servidor?"
    }
    var mensaje = {
	text: "Mensaje de KAI",
	channel: channel,
	attachments:[
            {
		        color: "warning",
                title: actionmessage,
                callback_id: "correct",
                attachment_type: "default",
                actions: [
                    {
                        name: "correct",
                        text: "Corregir",
                        value: "execute/"+actionstr,
                        type: "button",
			style: "primary",
			confirm: {
    				"title": "Confirme Acción Correctiva",
    				"text": "Confirmar la EJECUCIÓN de: "+actionmessage,
    				"ok_text": "Si",
    				"dismiss_text": "No"
			}
                    },
                    {
                        name: "cancel",
                        text: "Cancelar",
                        value: "cancel/"+actionstr,
                        type: "button",
			style: "danger",
			confirm: {
                                "title": "Confirme Cancelación",
                                "text": "Confirmar la CANCELACIÓN de: "+actionmessage,
                                "ok_text": "Si",
                                "dismiss_text": "No"
                        }
                    }
                ]
            }
        ]
    }
    bot.say(mensaje);
}

controller.on('interactive_message_callback', function(bot,message){
    macUserTmp = {
      name: message.user,
    };
    macUser = macUserTmp.name;
    var sourceChannel = message.channel;
    action = message.actions[0].value.split("/");
    if(action[0] == "cancel"){
        var action1;
        if(action[1] == "clk") action1="Correct Clock Drift on ["+action[3]+"]";
        if(action[1] == "svc") action1="Correct Service Status on ["+action[3]+"/"+action[4]+"/"+action[5]+"]";
        bot.replyInteractive(message,":warning: The action has been cancelled by user request ("+action1+")");
    	return;
    }
    bot.replyInteractive(message,":animatedhourglass: Executing action...");
    var localts = Math.round((new Date()).getTime() / 1000);
    console.log(message.actions[0].value+" - "+action[1]+" - "+localts+" - "+maxButtonLifetimeSecs+" = "+(parseInt(action[2])-parseInt(localts)));

    if (Math.abs(parseInt(action[2])-parseInt(localts)) > maxButtonLifetimeSecs){
	bot.replyInteractive(message,":bangbang: The action of this button has expired (more than "+maxButtonLifetimeSecs+" seconds ago). Re-run checklist to get a new action button");
	return;
    }
    var command;
    if (action[0] == "execute"){
    	if(action[1] == "clk"){
            command = "ssh api01 '/gluster/apifs/home/sakio/scripts/correctServerDrift.sh "+action[3]+"'";
            console.log("----- "+command);
            execGetSimpleOutputPromise(command).then(function(value){postActionResult(message,value)});
    	}
    	else if(action[1] == "svc"){
            command = "ssh api01 '/gluster/apifs/home/sakio/scripts/correctService.sh \""+action[3]+"\""+" \""+action[4]+"/"+action[5]+"\"'";
            console.log("----- "+command);
            //bot.replyInteractive(message,command);
            execGetSimpleOutputPromise(command).then(function(value){postActionResult(message,value)});
    	}
        else{
            bot.replyInteractive(message,":x: ERROR: Invalid action ("+action[0]+").");
    	return;
        }

    }
});

function triggerMessage(channel,messageString){
    var mensaje={"text": messageString,"channel": channel};
    bot.say(mensaje);
    botTalk(channel,messageString);
}

function postActionResult(message,result){
    console.log("-------------- Replying message: "+result);
    var messageStyle="warning";
    var messageTitle="-";
    if(result.includes(":x:")){
        messageStyle="danger";
        messageTitle="Error al ejecutar la acción!!!";
    }
    if(result.includes(":heavy_check_mark:") || result.includes(":information_source:")){
        messageStyle="good";
        messageTitle="Acción ejecutada correctamente!!!";
    }
    var mensaje = {
        text: "Resultado de la ejecución",
        channel: message.channel,
        attachments:[
            {
                color: messageStyle,
                title: messageTitle,
                text: result,
                attachment_type: "default"
            }
        ]
    }
    bot.replyInteractive(message,mensaje);
}
