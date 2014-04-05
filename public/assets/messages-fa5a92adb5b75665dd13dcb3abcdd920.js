$(document).ready(function(){
	
	var DEFAULT_PAGING = {"from" : 0, "size" : 6};
	var messages = {
		"received" : {
			"from" : 0,
			"size" : 8,
			"sort_by" : "date",
			"search_term" : null,
			"selected" : []
		},
		"sent" : {
			"from" : 0,
			"size" : 8,
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
	
	$("#show-received-messages").live("click", function(e){
		type = "received";
		messages.set_term(type, "");
		messages.reset_paging(type);
		
		search("messages", messages.get_params(type));
	});
	
	$("#show-sent-messages").live("click", function(e){
		type = "sent";
		
		messages.set_term(type, "");
		messages.reset_paging(type);
		
		search("messages", messages.get_params(type));
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
    
    $(".message").live("mouseover", function(){
    	$(this).find(".select-message").show();
    	$(this).find(".remove-message").show();
    	$(this).find(".remove-message").css({"display" : "inline"});
    });
    
    $(".message").live("mouseleave", function(){
    	$(this).find(".select-message").hide();
    	$(this).find(".remove-message").hide();
    });
    
    $(".select-message").live("change", function(){
    	var message_id = $(this).parent().parent().attr("id");
    	var checked = $(this).checked;
    	
    	if(checked){
    		messages.select(type, message_id);
    	}
    	else{
    		messages.unselect(type, message_id);
    	}
    });
    
    $("a.read-message").live("click", function(){
    	$(".messages-center").html("<div id = 'loading_big' class='loading center'><img src = '/loading.gif' width = '24px' height = '24px' /></div>");
    });
    
    $("form.send-message").live("submit", function(){
    	if($("#send_message_loading").length === 0) $(this).append("<img src='/loading.gif' id='send_message_loading' width='16px' height='16px' />")
    });
    
    // example of using js_data
    // js_vars.set("some", "value");
    // setTimeout(function(){}, 500);
    // alert(js_vars.get("selected"));
    // alert(js_vars.get("some"));
    
});
