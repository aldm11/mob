var io = require("socket.io").listen(4000);

var redis = require("redis");
store_client = redis.createClient();

var PROPERTIES = ["account_id", "username", "image", "name", "email"];
var sockets = {};

// TODO 1: 	memory managnement for sockets array, if 2 sockets it seems that it takes 2 MBS of space, for 10 000 online users 10 GB should be used which is topo much
//			store this data in mongodb when user logged in/logged out, if use this check if sender and rec is in sockets must be deleted for performance reasons
//			then we have to store data in mongodb for user socket when that user is logged in and delete it when it is logged out
//			changes needs to be made in getting online list, is online and in getting conversations

// TODO 2:	handle backup of conversations from redis to mongodb, when redis is full so data can be saved to mongo
//			change needs to be made in getting conversations for every user so if data can be saved in redis (it has space) data is saved there, otherwise data is saved in mongo
//			same change should be made in storing message (maybe using external process for performance reasons)	 

io.sockets.on("connection", function(socket){
	socket.on("login", function(account){
		try{
			var success = true;			
			for(var i = 0; i < PROPERTIES.length; i++){
				var prop = PROPERTIES[i];
				socket.set(prop, account[prop], function(err){
					if(err){
						console.log("Error while setting prop " + prop + " : " + err);
						success = false;
					}
				});
			}
			
			if(success){
				sockets[account["account_id"]] = socket;
				socket.emit("login_complete");
				socket.broadcast.emit("user_logged_in", account);
			}
			console.log(sockets);
		}
		catch(exc){
			process.stderr.write("\nError while login " + exc + "\n");
		}
	});
	
	socket.on("disconnect", function(){
		try{
			socket.get("account_id", function(err, account_id){
				if(err){
					console.log("Error while getting account_id for socket " + socket.id);
				}
				else{
					console.log("Disconnect event for " + account_id);
				}
			});
		}
		catch(exc){
			process.stderr.write("\nError while disconnecting " + exc + "\n");
		}
	});
	
	socket.on("logout", function(account_id){
		try{
			console.log("Logout socket for account " + account_id);
			
			store_client.lrange(["conversations", account_id].join(":"), 0, -1, function(err, messages){
				for(var key in messages){
					console.log("jedan kljuc "+key+" "+messages[key]);
				}
			});
			
			delete sockets[account_id];			
			store_client.del(["conversations", account_id].join(":"));
			
			store_client.lrange(["conversations", account_id].join(":"), 0, -1, function(err, messages){
				for(var key in messages){
					console.log("jedan kljuc "+key+" "+messages[key]);
				}
			});

			socket.broadcast.emit("logout", account_id);
		}
		catch(exc){
			process.stderr.write("\nError while logout " + exc + "\n");
		}
	});
	
	socket.on("isOnline", function(source, target){
		if(source && sockets[source] && target && sockets[target]){
			sockets[source].emit("isOnlineReply", true);
		}
		else{
			socket.emit("isOnlineReply", false);
		}
	});
	
	socket.on("onlineList", function(source){
		// console.log("Size of socket object " + roughSizeOfObject(sockets));
		try{
			accounts = [];
			if(source && sockets[source]){
				for(var account_id in sockets){					
					if(account_id !== source){
						console.log("dodavanje "+account_id);
						console.log(get_account(account_id));
						accounts.push(get_account(account_id));
					}
				}
			}
			socket.emit("onlineListReply", accounts);
		}
		catch(exc){
			process.stderr.write("\nError while getting online list " + exc + "\n");			
		}
	});
	
	socket.on("clientMessage", function(message){
		var sender_id = message["sender_id"];
		var receiver_id = message["receiver_id"];
		if(sender_id && receiver_id && sockets[sender_id] && sockets[receiver_id]){
			console.log("Sending message from " + sender_id + " to " + receiver_id + " : " + message);
			sockets[receiver_id].emit("message", message);
			
			store_message(message);
		}
		else{
			console.log("Can't send message between offline sides");
		}
	});
	
	socket.on("getConversations", function(account_id){
		console.log("Getting conversations for user id " + account_id);
		conversations = {};
		
		store_client.lrange(["conversations", account_id].join(":"), 0, -1, function(err, messages){
			for(var key in messages){
				var mess = messages[key];
				var message = JSON.parse(mess);
				var other_part_id = message.sender_id === account_id ? message.receiver_id : message.sender_id;
				
				console.log("jedna "+mess+" "+other_part_id);

				if(conversations[other_part_id] === undefined){
					conversations[other_part_id] = {};
					conversations[other_part_id].messages = [];
					
					if(accounts[account_id] === undefined){
						conversations[other_part_id].offline = true;
					}
				}
				conversations[other_part_id].messages.push(message);
			};
			
			console.log("Conversation list " + JSON.stringify(conversations));
			socket.emit("conversations", conversations);
		});
	});
	
	function store_message(message){
		store_client.rpush(["conversations", message.sender_id].join(":"), JSON.stringify(message));
		store_client.rpush(["conversations", message.receiver_id].join(":"), JSON.stringify(message));
	}
	
	function get_account(account_id){
		var socket = sockets[account_id];
		var socket_details = {};
		for(var i = 0; i < PROPERTIES.length; i++){
			var prop = PROPERTIES[i];
			socket.get(prop, function(err, val){
				if(err){
					console.log("Error while getting prop " + prop + " for socket " + socket.id);
				}
				else{
					socket_details[prop] = val;
				}
			});
		}
		return socket_details;
	}
	
	function roughSizeOfObject( object ) {
	    var objectList = [];
	
	    var recurse = function( value )
	    {
	        var bytes = 0;
	
	        if ( typeof value === 'boolean' ) {
	            bytes = 4;
	        }
	        else if ( typeof value === 'string' ) {
	            bytes = value.length * 2;
	        }
	        else if ( typeof value === 'number' ) {
	            bytes = 8;
	        }
	        else if(typeof value === 'object' && objectList.indexOf( value ) === -1)
	        {
	            objectList[ objectList.length ] = value;
	
	            for( i in value ) {
	                bytes+= 8; // an assumed existence overhead
	                bytes+= recurse( value[i] )
	            }
	        }
	
	        return bytes;
	    }
	
	    return recurse( object );
	}
	
});
