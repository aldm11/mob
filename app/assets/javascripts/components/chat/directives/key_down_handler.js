//var chat_app = angular.module("chat");
//chat_app.directive("keydownHandler", 
var key_down_hanlder = function(){
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
};
//});