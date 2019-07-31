// Configure debugging (requires DEBUG enviromente variable to enable)
var debug = require('debug')("controller");

// Try to find configuration file 'bot_config.js'
if (process.env.botpath) {
    bot_path=process.env.botpath;
}
else {
    bot_path='.'
}
try {
        require(bot_path+'/bot_config.js');
        debug('Loading config file. Using file: '+bot_path+'/bot_config.js');
}
catch (e){
    console.log('Error. Could not locate configuration file (define and export "botpath" environment variable)');
    process.exit(1);
}

// Check if variable token is defined
if (typeof token === 'undefined') {
    console.log('Error: Specify token in environment');
    debug('The configuration variable "token" is not defined.');
    process.exit(1);
}

// Check if variables to configure WebServer are defined.
if (typeof clientId === 'undefined') { debug('Warning: clientID not defined.'); }
if (typeof clientSecret === 'undefined') { debug('Warning: clientSecret not defined'); }
if (typeof botPort === 'undefined') { debug('Warning: botPort not defined'); }

// Load BotKit Module
Botkit = require('botkit/lib/Botkit.js');
os = require('os');

// Check if useRTM is enabled (disable if using Interactive Messages to avoid duplicate messages)
if (!(typeof(useRTM) === "boolean")){
    debug("Warning: useRTM config variable it's not defined or it's not a boolean. Using 'true' as default");
    useRTM = false;
}
// Check if useInteractiveReplies is enabled (disable if using Interactive Messages to avoid duplicate messages)
if (!(typeof(useInteractiveReplies) === "boolean")){
    debug("Warning: useRTM config variable it's not defined or it's not a boolean. Using 'false' as default");
    useInteractiveReplies = false;
}

// Check if RTM API and Interactive Replies are both ehosnabled (causes duplicate messages)
if((useRTM == true) && (useInteractiveReplies == true)){
    console.log("Warning: RTM API (useRTM) and Interactive Messages (useInteractiveReplies) are both enabled. This can cause duplicate messages in bot app.");
}

// Prints a message in debug is enabled
if(enableDebug){ console.log("Info: Debug ENABLED"); }

// MongoDB configuration
var mongoStorage = require('botkit-storage-mongo')({mongoUri: mongoURI});

// Initial configuration of contoller
controller = Botkit.slackbot({
    storage: mongoStorage,
    interactive_replies : useInteractiveReplies,
    debug: enableDebug,
    require_delivery: true,
    rtm_receive_messages: useRTM
});

// Add configuration to controller in case that enableWebServer is true
if (enableWebServer == true){

    controller.configureSlackApp({
      clientId: clientId,
      clientSecret: clientSecret,
      scopes: ['bot'],
    });

    controller.setupWebserver(botPort,function(err,webserver) {
      controller.createWebhookEndpoints(controller.webserver);

      controller.createOauthEndpoints(controller.webserver,function(err,req,res) {
        if (err) {
          res.status(500).send('ERROR: ' + err);
        } else {
          res.send('Success!');
        }
      });
    });
}

// Function to avoid duplicate running bots
var _bots = {};
function trackBot(bot) {
  _bots[bot.config.token] = bot;
}

// Spawn controller object
bot = controller.spawn({
    retry: true,
    token: token
}).startRTM();

Crypto = require('crypto');
Array.prototype.sample = function() {
  var buf = Crypto.randomBytes(2);
  var index = buf.readUInt16BE(0) % this.length;
  return this[index];
}

// Load Modules specified in loadCommonModules and loadModules variable
var moduleFileName;
debug("Loading common modules...")
for (var i=0, len = loadCommonModules.length; i < len; i++){
    moduleFileName=bot_comm_mod_path+'module_'+loadCommonModules[i]+'.js';
    debug("Trying to load common module file: %s",moduleFileName);
    try{
            require(moduleFileName);
    }
    catch (e){
        console.log("ERROR: Could not load module file "+moduleFileName);
        console.log(e);
    }
}
debug("Loading modules...")
for (var i=0, len = loadModules.length; i < len; i++){
    moduleFileName=bot_path+'/bot_modules/'+'module_'+loadModules[i]+'.js';
    debug("Trying to load module file: %s",moduleFileName);
    try{
        if(loadModules[i] == "loadbots"){
            var moduleTmp = require(moduleFileName);
            botDetails = moduleTmp.BotList;
            //debug(botDetails);
        }
        else{
            require(moduleFileName);
        }
    }
    catch (e){
        console.log("ERROR: Could not load module file "+moduleFileName);
        console.log(e);
    }
}
