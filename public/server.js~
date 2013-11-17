var io = require("socket.io").listen(4000);
io.sockets.on("connection", function(socket){
	console.log("Connection established");
	socket.on("clientMessage", function(content){
		socket.broadcast.emit("serverMessage", socket.id + " said " + content);
	});
});
