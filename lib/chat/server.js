var io = require("socket.io").listen(4000);

var PROPERTIES = ["account_id", "username", "image", "name", "email"];
var sockets = {};
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
					console.log("Deleting socket for account " + account_id + " from list");
					delete sockets[account_id];
					socket.broadcast.emit("disconnect", account_id);
				}
			});
		}
		catch(exc){
			process.stderr.write("\nError while disconnecting " + exc + "\n");
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
		try{
			accounts = [];
			if(source && sockets[source]){
				for(var account_id in sockets){
					if(account_id !== source){
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
		}
		else{
			console.log("Can't send message between offline sides");
		}
	});
	
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
	
});
