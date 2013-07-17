var io = require("socket.io").listen(4000);

var sockets = {};
io.sockets.on("connection", function(socket){
	//sockets[socket.id] = socket;
	//console.log(sockets);
	socket.on("login", function(username){
		socket.set("username", username, function(err){
			if(err){
				
			}
			else{
				socket.emit("loginSuccess", "Logged in as " + username);
				sockets[username] = socket;
				console.log(sockets);
			}
		});
	});
	
	socket.on("clientMessage", function(message){
		console.log("New message to " + message["receiver"] + " : " + message["content"]);
		var sender = message["sender"];
		var receiver = message["receiver"];
		if(sockets[sender] !== undefined && sockets[receiver] !== undefined){
			console.log("Sending message to " + message["receiver"] + " : " + message);
			sockets[receiver].emit("clientMessage", message);
		}
	});
	
	socket.on("disconnect", function(){
		delete sockets[socket.id];
	});
});
