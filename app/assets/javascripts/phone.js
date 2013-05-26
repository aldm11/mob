$(document).ready(function(){
	$(".last-phone-offer").popover({html: true, delay: 500, trigger: "hover"});
	
	var KEY_ENTER = 13;
	$('#comment_text').live("keydown", function (event) {
    	if (event.keyCode === KEY_ENTER){
	    	if (event.ctrlKey){
				$(this).val($(this).val()+"\n");
	    	}
	    	else{
				event.preventDefault();
	    		$("form#new_comment").submit();	
	    	}
	    }
	});
	
	var COMMENTS_PER_PAGE = 10;
	var from = 0;
	var size = COMMENTS_PER_PAGE;
	
	var get_params_comments =  function(){
	   var params = {
			"from" : from,
			"size" : size,
			"phone_id" : $("#phone_id").val()
		}
		return params;
	}
	
	$("#load_more_comments").live("click", function(){
		from += size;
		search("comments", get_params_comments());
	});
	
});