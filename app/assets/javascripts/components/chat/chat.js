angular.element(document).ready(function(){
	var chat_app = angular.module("Chat", []);
	chat_app.controller("keydownHandler", ["$scope", "$timeout", "$http", "ChatService", key_down_hanlder]);
	chat_app.factory("ChatService", ["$http", "$log", "$q", "$rootScope", ChatService]);
	chat_app.controller("ChatController", ["$scope", "$timeout", "$http", "ChatService", ChatController]);
	angular.bootstrap(angular.element(document), ["Chat"]);
	
});
// TODOS:
//			organize all sockets operations in one service (connect in constructor and other in methods) 
//			so chat app can be independent from libraru used for communicating with node server
//			support for configuration parameter which tells if chat turned off/on - this would be handy when maintainance in progress
//			maybe move chat html from application.html.erb to view file to make app non-dependent 
//			do all other improvements to make this chat reusable in other web apps with as small changes as it is  possible
//chat_app.controller("ChatController", ["$scope", "$timeout", "$http", ChatController]);
