$(document).ready(function(){
	$(".last-phone-offer").popover({html: true, delay: 500, trigger: "hover"});
	
	var KEY_ENTER = 13;
	$('#comment_text').keydown(function (event) {
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
	
});