$(document).ready(function(){
	var DEFAULT_PAGING = {"from" : 0, "size" : 3};
	var messages = {
		"received" : {
			"from" : 0,
			"size" : 3,
			"sort_by" : "date",
			"search_term" : null,
			"selected" : []
		},
		"sent" : {
			"from" : 0,
			"size" : 3,
			"sort_by" : "date",
			"search_term" : null,
			"selected" : []
		},
		"set_sort" : function(type, sort_by){
			this[type]["sort_by"] = sort_by;
		},
		"set_term" : function(type, term){
			this[type]["search_term"] = term;
		},
		"prev_page" : function(type){
			this[type]["from"] -= this[type]["size"];
		},
		"next_page" : function(type){
			this[type]["from"] += this[type]["size"];
		},
		"reset_paging" : function(type){
			this[type]["from"] = DEFAULT_PAGING["from"];
			this[type]["size"] = DEFAULT_PAGING["size"];
		},
		"get_params" : function(type){
			var params = this[type];
			params["type"] = type;
			return params;
		},
		"select" : function(type, message_id){
			if(this[type]["selected"].indexOf(message_id) === -1){
				this[type]["selected"].push(message_id);
			}
		},
		"unselect" : function(type, message_id){
			if(index = this[type]["selected"].indexOf(message_id) !== -1){
				this[type]["selected"].splice(index, 1);
			}
		},
		"unselect_all" : function(type){
			this[type]["selected"] = [];
		}
	};
	
	var type = "received";
	
	$("#show-received-messages").live("click", function(){
		type = "received";
	});
	
	$("#show-sent-messages").live("click", function(){
		type = "sent";
	});
	
	
	$("#sort_messages_date").live("click", function(){
		$(".sort-messages > a").toggleClass("disabled");
		messages.set_sort(type, "date");
		messages.reset_paging(type);
		
		search("messages", messages.get_params(type));
	});
	
	$("#sort_messages_unread").live("click", function(){
		$(".sort-messages > a").toggleClass("disabled");
		messages.set_sort(type, "unread");
		messages.reset_paging(type);
		
		search("messages", messages.get_params(type));
	});
	
	$("#messages_term").live("keyup", function(){
		messages.set_term (type, $(this).val());
		messages.reset_paging(type);
		
		search("messages", messages.get_params(type));
	});
	
	$(".messages-paging.prev").live("click", function(){
		messages.prev_page(type);
		
		search("messages", messages.get_params(type));
	});
	
	$(".messages-paging.next").live("click", function(){
		messages.next_page(type);
		
		search("messages", messages.get_params(type));
	});
    
});