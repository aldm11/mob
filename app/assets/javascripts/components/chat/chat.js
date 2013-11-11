var chat_app = angular.module("Chat", []);

// TODOS:
//			organize all sockets operations in one service (connect in constructor and other in methods) 
//			so chat app can be independent from libraru used for communicating with node server
//			support for configuration parameter which tells if chat turned off/on - this would be handy when maintainance in progress
//			maybe move chat html from application.html.erb to view file to make app non-dependent 
//			do all other improvements to make this chat reusable in other web apps with as small changes as it is  possible
chat_app.controller("ChatController", ["$scope", "$timeout", "$http", ChatController]);
chat_app.directive("keydownHandler", key_down_handler);
