// some kind of deleting conversations from time to time
// scroller on conversations
// maybe embedding chat html and css into component and somehow referenc it from some view - iframe or similar

//chat_app.controller("ChatController", ["$scope", "$timeout", "$http", "ChatService", 
var ChatController = function($scope, $timeout, $http, ChatService){
	$scope.PROPERTIES = ["account_id", "username", "image", "name", "email"];
	$scope.contacts = {};
	$scope.conversations = {};
	$scope.show_chat = true;
	$scope.account = null;
	//contacts should have size in bytes 130 * number_of_accounts so it should't be overhead for browser, check this out'
	
	var logged_out_user = null;
	var chat_service = null;
	
	// Event callbacks: message arrived, contact online and contact left
	$scope.$on("user_logged_in", function(event, account){
		$scope.contacts[account.account_id] = account;
		
		if($scope.conversations[account.account_id] !== undefined){
			$scope.conversations[account.account_id].offline = false;
		}
		$scope.$apply();
	});
	
	$scope.$on("message", function(event, message){
		console.log("dosla");
		console.log(message);
		var sender_id = message.sender_id;
		notifyMessageArrived(sender_id);
		$scope.conversations[sender_id].messages.push({"sender" : $scope.contacts[sender_id].name, "content" : message.content});
		$scope.$apply();
	});
	
	$scope.$on("logout", function(event, account_id){
		$scope.conversations[account_id].offline = true
		delete $scope.contacts[account_id];
		$scope.$apply();
	});
	
	$scope.index = function(session_info){
		$scope.account = session_info.user;
						
		if(angular.isObject(session_info.logged_out_user)){
			try{
				new ChatService(session_info.logged_out_user).logout();
			}
			catch(err) {}
		}
		else {
			try{
				chat_service = new ChatService($scope.account);
			} catch(err){}
		}
	
		if(chat_service){
			$scope.user_logged_in = true;

			chat_service.getOnlineList().then(function(accounts){
				updateContacts(accounts);
				
				chat_service.getConversations().then(function(conversations){
					updateConversations(conversations);
				}, function(err){			
				});
			}, function(err){
				
			});
		}
	};
	
	$scope.available = function(){
		return Configuration.enabled && chat_service !== undefined && chat_service !== null;
	};
	
	var CONVERSATION_WIDTH = 182;
	$scope.toggleConversation = function(contact_id){
		toggleConversation(contact_id);
	};
	
	$scope.sendMessage = function(contact_id){
		var message = $scope.conversations[contact_id].new_message;
		
		try {
			chat_service.sendMessage(contact_id, message);		
			$scope.conversations[contact_id].messages.push({"sender" : $scope.account.name, "content" : message});
			$scope.$apply();
		}
		catch(err){
			console.log("Error: " + err);
		}
	};
	
	$scope.showNoContacts = function(){
		return $scope.available() && angular.equals({}, $scope.contacts, {});
	};
	
	$scope.conversationDisabled = function(account_id){
		$scope.conversations[account_id].offline ? true : false;
	};
	
	function notifyMessageArrived(contact_id){
		var old_chat_width = $(".chat-content").width();
		var new_chat_width = old_chat_width;
		if($scope.conversations[contact_id] === undefined){
			$scope.conversations[contact_id] = {};
			$scope.conversations[contact_id]["details"] = $scope.contacts[contact_id];
			$scope.conversations[contact_id]["new_message"] = "";
			$scope.conversations[contact_id]["messages"] = [];
			
			$scope.conversations[contact_id]["show"] = true;
			
			new_chat_width += CONVERSATION_WIDTH;
		}
		else{
			if(!$scope.conversations[contact_id].show){
				new_chat_width += CONVERSATION_WIDTH;
			}

			$scope.conversations[contact_id].show = true;
		}				
		$(".chat-content").width(new_chat_width);
	}
	
	function toggleConversation(contact_id){
		var old_chat_width = $(".chat-content").width();
		var new_chat_width = old_chat_width;
		if($scope.conversations[contact_id] === undefined){
			$scope.conversations[contact_id] = {};
			$scope.conversations[contact_id].details = $scope.contacts[contact_id];
			$scope.conversations[contact_id].new_message = "";
			$scope.conversations[contact_id].messages = [];
			$scope.conversations[contact_id].started = (new Date()).getTime();
							
			$scope.conversations[contact_id].show = true;
			
			new_chat_width += CONVERSATION_WIDTH;
		}
		else{
			$scope.conversations[contact_id].show = !$scope.conversations[contact_id].show;
			
			$scope.conversations[contact_id].show ? new_chat_width += CONVERSATION_WIDTH : new_chat_width -= CONVERSATION_WIDTH;
		}
		$(".chat-content").width(new_chat_width);
	}
	
	function updateContacts(accounts){
		var online_accounts = {};
		for(var i = 0; i < accounts.length; i++){
			var account = accounts[i];
			if($scope.contacts[account.account_id] === undefined){
				$scope.contacts[account.account_id] = account;
			}
			else{
				for(var i = 0; i < $scope.PROPERTIES.length; i++){
					$scope.contacts[account.account_id][$scope.PROPERTIES[i]] = account[$scope.PROPERTIES[i]];
				}
			}
			online_accounts[account.account_id] = 1;
		}
		
		for(var account_id in $scope.contacts){
			if(online_accounts[account_id] === undefined){
				delete $scope.contacts[account_id];
			}
		}
	}
	
	function updateConversations(server_conversations){
		for(var account_id in server_conversations){
			if($scope.contacts[account_id]){
				toggleConversation(account_id);
				
				for(var i = 0; i < server_conversations[account_id].messages.length; i++){
					var sender_id = server_conversations[account_id].messages[i].sender_id;
					var sender_name = sender_id === $scope.account.account_id ? $scope.account.name : $scope.contacts[sender_id].name;
					var mess = {"sender" : sender_name, "content" : server_conversations[account_id].messages[i].content};									
					
					$scope.conversations[account_id].messages.push(mess);									
				}
			}		
		}
	}
}
//}]);