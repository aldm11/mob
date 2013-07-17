var httpd = require('http').createServer(handler);
var io = require('socket.io').listen(httpd);
var fs = require('fs');
httpd.listen(4000);
function handler(req, res) {
	fs.readFile(__dirname + '/index1.html', function(err, data) {
		if (err) {
			res.writeHead(500);
			return res.end('Error loading index.html');
		}
		res.writeHead(200);
		res.end(data);
	});
}
io.sockets.on('connection', function (socket) {
	socket.on('clientMessage', function(content) {
		console.log("Client message " + content + "arrived");
		socket.emit('serverMessage', 'You said: ' + content);
		socket.broadcast.emit('serverMessage', socket.id + ' said: ' + content);
	});
	
	socket.on("login", function(username){
		socket.set("username", username, function(err){
			if(err){
				console.log("Error while setting username to " + username + err);
			}
			else{
				socket.emit("serverMessage", "Logged in as " + username);
			}
		})
	});
	
	socket.emit("login");
});