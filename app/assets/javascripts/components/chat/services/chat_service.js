var char_app = angular.module("Chat");
chat_app.factory("ChatService", ["$http", "$log", "$q", "$rootScope", function($http, $log, $q, $rootScope){
	
	var chat_service = {};
	var socket = null;
	var enabled = false;
	var account = null;
		
	chat_service.checkAndInit = function(acc){
		account = acc;
		if(socket !== null) return true;
		
		try {
			socket = io.connect("http://localhost:4000");
			
			socket.on("user_logged_in", function(account){
				$rootScope.$broadcast("user_logged_in", account);
			});
			
			socket.on("message", function(message){				
				$rootScope.$broadcast("message", message);
			});
			
			socket.on("logout", function(account_id){
				$rootScope.$broadcast("logout", account_id);
			})
			
			return true;
		} catch(err){
			console.log("Warning : Can't connect to chat server");
			return false;
		}
	};
	
	chat_service.enabled = function(){
		return $http.get("/api/V1/chat/config").then(function(response){
			return response.data["enabled"];
		}, function(error){
			return false;
		});
	};
	
	chat_service.login = function(account){
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
	
	chat_service.getOnlineList = function(account){
		var deferred = $q.defer();
		
		chat_service.login(account).then(function(acc){
			socket.emit("onlineList", account.account_id);
			
			socket.on("onlineListReply", function(accounts){
				console.log("accounts");
				deferred.resolve(accounts);
				$rootScope.$apply();
			});		
		}, function(err){
			deferred.reject();
		});
		
		return deferred.promise;
	}
	
	chat_service.getConversations = function(account){
		var deferred = $q.defer();
		
		socket.emit("getConversations", account.account_id);
		socket.on("conversations", function(conversations){
			console.log(conversations);
			deferred.resolve(conversations);
			$rootScope.$apply();
		});
		
		return deferred.promise;
	}
	
	chat_service.sendMessage = function(from, to, message){
		socket.emit("clientMessage", {"sender_id" : from, "receiver_id" : to, "content" : message.content});	
	}
	
	return chat_service;
}]);
