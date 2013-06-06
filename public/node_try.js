var http = require("http");

http.createServer(function(request, response){
	request.on("end", function(){
		console.log("kraj");
	});
	response.writeHead(200, {"Content-Type": "text/plain"});
	response.write("Hello World");
	response.end();
}).listen(8080);
