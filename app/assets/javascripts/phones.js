$(document).ready(function(){
	$(".last-phone-offer").popover({html: true, delay: 500, trigger: "hover"});
	$(".provider-details").popover({html: true, delay: 500, trigger: "hover"});
	
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
	
	$("#comment_text").tooltip({trigger: ["focus", "hover"]});
	
	var COMMENTS_PER_PAGE = 10;
	var OFFERS_PER_PAGE = 1;
	var comment_from = 0;
	var comment_size = COMMENTS_PER_PAGE;
	
	var offer_from = 0;
	var offer_size = OFFERS_PER_PAGE;
	var offer_sort_by = "date";
	
	var get_params_comments =  function(){
	   var params = {
			"from" : comment_from,
			"size" : comment_size,
			"phone_id" : $("#phone_id").val()
		}
		return params;
	}
	
	var get_params_offers =  function(){
	   var params = {
			"from" : offer_from,
			"size" : offer_size,
			"phone_id" : $("#phone_id").val(),
			"sort_by" : offer_sort_by
		}
		return params;
	}
	
	$("#load_more_comments").live("click", function(){
		comment_from += comment_size;
		search("comments", get_params_comments());
		return false;
	});
	
	$("#load_more_offers").live("click", function(){
		offer_from += offer_size;
		search("offers", get_params_offers());
		return false;
	});
	
	$("#sort_by_date").live("click", function(event){
		event.preventDefault();
		$("#sort_by_date").toggleClass("disabled");
		$("#sort_by_price").toggleClass("disabled");

		offer_sort_by = "date";
		offer_from = 0;
		offer_size = OFFERS_PER_PAGE;
		search("offers", get_params_offers());
	});
	
	$("#sort_by_price").live("click", function(event){
		event.preventDefault();
		$("#sort_by_date").toggleClass("disabled");
		$("#sort_by_price").toggleClass("disabled");

		offer_sort_by = "price";
		offer_from = 0;
		offer_size = OFFERS_PER_PAGE;
		search("offers", get_params_offers());
	});
	
	
	$(".add-comment-main").live("mouseover", function(){
		$(this).tooltip("show");
	});
	
});