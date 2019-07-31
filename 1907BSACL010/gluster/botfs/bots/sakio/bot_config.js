// Define if bot is enabled (should be running: true) or not (false)
bot_enabled=true;
// UUID to identify bot and process (can use uuidgen command to generate a new one)
bot_uuid = '713e49fe-dece-433a-968b-d936b679c6cb';
// Bot name
bot_name = 'sakio';
// Bot User Name
bot_user = 'sakio';
bot_client = 'ServiceAssurance';
stats_enabled = true;
// Bot Description
bot_desc = 'Chatbot for Service Assurance Team';
// Bot Slack Workspace Name
bot_workspace = 'sa-kio.slack.com';
// API endpoint type (ssh, powershell, http, etc...)
api_endpoint_type = '';
// API endpoint URL
api_endpoint_uri = '';

// ################################# SLACK CONNECTION DETAILÑS
// token: API token to connect to Slack Bot User. Example:
token = 'xoxb-534981952262-533439382340-22QMLrrzKeWF1ovEQ79cds5j';
// clientId: ID of client app on slack
clientId = '534981952262.535010818854';
// clientSecret: Secret token of client app on Slack
clientSecret = 'aee2c43c40f71b9d1dcafc960f0f4021';
enableMessagesIPC = true;
stats_enabled=true;
// ################################# MongoDB configuration
mongoURI = 'mongodb://db_user_sakio:tYuRUt3BZCM@db01,db02,db03/db_sakio?replicaSet=rs0';
mongoUser = 'db_user_sakio';
mongoDB = 'db_sakio';

// ################################# RASA URI
bot_rasa_uri = 'Not Defined';
bot_rasa_enabled = false;

// ################################# BOT CONFIGURATION DETAILS
// common_modules Path
bot_comm_mod_path='/gluster/botfs/common_modules/';
// bot_path: Path of the .js file containing the bot code
bot_path = '/gluster/botfs/bots/sakio/';
// Log File location
logFile='/gluster/botlogfs/sakio/bot.log';
// Enable or disable NodeJS debug mode
enableDebug = true;
// Enable or disable NodeJS server automatic reload in case of source code change (supervised)
enableNodeSupervisor = true;
// Enable use of tmpCommon filesystem to pass messages to Bot
enableMessagesIPC = false;
// enableWebServer: Whether or not enable WebServer for listening Interactive Messages events.
enableWebServer = true;
// botPort: Port in wich to listen events API from Slack.
botPort = '8091';
// useRTM: Enable or disable RTM API (disable if we're going to enable interactiveMessages API to avoid duplicate messages). Valid values are: true or false (without quotes)
useRTM = false;
// useInteractiveReplies: Enable or disable Interactive Replies (interactive messages). Valid values are: true or false (wihtout quotes). If enabled, set useRTM to "false"
useInteractiveReplies = true;
// Load Common bot modules
loadCommonModules = ["commandexecute","stats"];
// loadModules: (array) list of modules to load automatically at bot startup
loadModules = ["watchmessages","reporte","receivefile"];
// Slack channel for Admin Group Messages
defaultAdminChannel = "";
// Location of BotKit module file

// ################################# ADDITIONAL LOCAL GLOBAL VARIABLES
