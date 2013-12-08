angular.element(document).ready(function(){
	var chat_app = angular.module("Chat", []);
	chat_app.controller("keydownHandler", ["$scope", "$timeout", "$http", "ChatService", key_down_hanlder]);
	chat_app.factory("ChatService", ["$http", "$log", "$q", "$rootScope", ChatService]);
	chat_app.controller("ChatController", ["$scope", "$timeout", "$http", "ChatService", ChatController]);
	angular.bootstrap(angular.element(document), ["Chat"]);
	
});
// TODOS:
//			maybe move chat html from application.html.erb to view file to make app non-dependent 
//			do all other improvements to make this chat reusable in other web apps with as small changes as it is  possible
// 			maybe use ajax to include all js dependencies in chat.js instead of loading it in application.js.erb