db = db.getSiblingDB('db_sakio');
db.createUser(
   {
	user: "db_user_sakio",
	pwd: "tYuRUt3BZCM",
	roles: [ { role: "readWrite", db: "db_sakio" } ]
   }
)
