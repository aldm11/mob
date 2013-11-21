//var chat_app = angular.module("chat");
//chat_app.factory("ChatService", ["$http", "$log", "$q", "$rootScope", 
var ChatService = function($http, $log, $q, $rootScope){
	return function(user_account){
		var socket = null;
		var enabled = false;
		var account = user_account;
		
		if(!angular.isObject(user_account)) throw "Invalid user";
				
		socket = io.connect("http://localhost:4000");
		
		socket.on("user_logged_in", function(account){
			$rootScope.$broadcast("user_logged_in", account);
		});
		
		socket.on("message", function(message){				
			$rootScope.$broadcast("message", message);
		});
		
		socket.on("logout", function(account_id){
			$rootScope.$broadcast("logout", account_id);
		});	
		
		var chat_service = {};
		
		chat_service.login = function(){
			var deferred = $q.defer();
			
			if(socket){
				console.log("Logging in to server");
				socket.emit("login", account);
				
				socket.on("login_complete", function(){
					deferred.resolve(true);
					$rootScope.$apply();
				});
			}
			else {
				deferred.reject();
			}
			return deferred.promise;
		};
		
		chat_service.getOnlineList = function(){
			var deferred = $q.defer();
			
			chat_service.login().then(function(acc){
				socket.emit("onlineList", account.account_id);
				
				socket.on("onlineListReply", function(accounts){
					console.log("Chat service contacts");
					deferred.resolve(accounts);
					$rootScope.$apply();
				});		
			}, function(err){
				deferred.reject();
			});
			
			return deferred.promise;
		}
		
		chat_service.getConversations = function(){
			var deferred = $q.defer();
			
			socket.emit("getConversations", account.account_id);
			socket.on("conversations", function(conversations){
				console.log("Chat service conversations:");
				console.log(conversations);
				deferred.resolve(conversations);
				$rootScope.$apply();
			});
			
			return deferred.promise;
		}
		
		chat_service.sendMessage = function(to, message){
			console.log({"sender_id" : account.account_id, "receiver_id" : to, "content" : message});		
			socket.emit("clientMessage", {"sender_id" : account.account_id, "receiver_id" : to, "content" : message});	
		}
		
		chat_service.logout = function(){			
			socket.emit("logout", account.account_id);
		}
		
		return chat_service;
	};
};
//}]);
