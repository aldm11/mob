var chat_app = angular.module("Chat", []);

chat_app.controller("ChatController", ["$scope", "$timeout",
	function ChatController($scope, $timeout){
		$scope.PROPERTIES = ["account_id", "username", "image", "name", "email"];
		
		$scope.contacts = {};
		$scope.conversations = {};
		
		var user = $("#user").html();
		
		$scope.account = user ? JSON.parse(user) : user;
		$scope.socket = null;
		$scope.available = true;
		
		try {
			$scope.socket = io.connect("http://localhost:4000");
			$scope.available = true;
		} catch(err){
			console.log("Warning : Can't connect to chat server");
			$scope.available = false;
		}
		
		$scope.index = function(){
			if($scope.socket && $scope.account){
				console.log("Logging in to server");
				$scope.socket.emit("login", $scope.account);
				
				$scope.socket.on("login_complete", function(){
					$scope.socket.emit("onlineList", $scope.account.account_id);
					
					$scope.socket.on("onlineListReply", function(accounts){
						updateContacts(accounts);
						console.log($scope.contacts);
					});
				});
				
				$scope.socket.on("user_logged_in", function(account){
					$scope.$apply(function(){
						if($scope.contacts[account.account_id] ===  undefined){
							for(var i = 0; i < $scope.PROPERTIES.length; i++){
								$scope.contacts[account.account_id] = account;
							}
						}
					});
				});
				
				$scope.socket.on("message", function(message){
					$scope.$apply(function(){
						var sender_id = message.sender_id;
						notifyMessageArrived(sender_id);
						$scope.conversations[sender_id].messages.push({"sender" : $scope.contacts[sender_id].name, "content" : message.content});
					});
				});
				
				$scope.socket.on("disconnect", function(account_id){
					$scope.$apply(function(){
						delete $scope.contacts[account_id];
					});
				})
			}
		};
		
		var CONVERSATION_WIDTH = 182;
		$scope.toggleConversation = function(contact_id){
			toggleConversation(contact_id);
		};
		
		$scope.sendMessage = function(contact_id){
			var message = $scope.conversations[contact_id].new_message
			
			$scope.$apply(function(){
				$scope.conversations[contact_id].messages.push({"sender" : $scope.account.name, "content" : message});
		    	$scope.socket.emit("clientMessage", {"sender_id" : $scope.account.account_id, "receiver_id" : contact_id, "content" : message});
			});
		};
		
		$scope.showNoContacts = function(){
			return angular.equals({}, $scope.contacts, {}) && $scope.available;
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
			console.log($scope.conversations);
		}
		
		function updateContacts(accounts){
			var online_accounts = {};
			$scope.$apply(function(){
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
			});
		}
	}
]);

chat_app.directive("keydownHandler", function(){
	return {
		restrict: "A",
		link: function(scope, element, attrs){
			element.keydown(function(event){
				if(event.keyCode === 13 || event.which === 13){
					console.log(attrs.keydownHandler);
					var handler = attrs.keydownHandler.split(",")[0];
					scope[handler].apply(scope, [attrs.keydownHandler.split(",")[1]]);
					element.val("");
				};
			});
		}
	}
});
