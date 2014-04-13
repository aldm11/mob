$(document).ready(function(){
	// phones#index
	var min_price = 50,
	    max_price = 1000;
	
	var search_term = $("#search_term").val() || "", 
	    brand = $("#brand_param").val() || "", 
	    sort_by = $(".sort-phones-by a:nth-child(1)").attr("id"),
	    from = 0,
	    size = 16;
	
	var reset_price_range = function(){
		$(".price-from-text").html(min_price);
		$(".price-to-text").html(max_price);
		$("#price_from").val(min_price);
		$("#price_to").val(max_price);
		price_from = min_price;
		price_to = max_price;
		$("#price-slider").slider("values", 0, min_price);
		$("#price-slider").slider("values", 1, max_price);
	}
	
	var reset_advanced_search = function(){
		$("#advanced_search").find("select").each(function(){
			$(this).prop('selectedIndex', 0);
		});
	}
	
	var get_params =  function(){
	   var params = {
			"search_term" : search_term,
			"sort_by" : sort_by,
			"price_from" : $("#price_from").val(),
			"price_to" : $("#price_to").val(),
			"from" : from,
			"size" : size
		};
		if(brand) params["brand"] = brand;
		
		var filters = ["brand", "operating_system", "weight", "display_type", "internal_memory", "external_memory", "camera_mpx", "camera_blic", "camera_front", "camera_video"];
		for(var i = 0; i < filters.length; i++){
			var param_name = filters[i];
			if($("#"+param_name).val()) params[param_name] = $("#"+param_name).val(); 
		}
		return params;
	}
	
	$("#price-slider").slider({
		range: true, 
		min: min_price, 
		max: max_price, 
		values : [min_price, max_price],
		slide: function( event, ui ) {
			$(".price-from-text").html(ui.values[0]);
			$(".price-to-text").html(ui.values[1]);
			$("#price_from").val(ui.values[0]);
			$("#price_to").val(ui.values[1]);
		}
	});
	
	$(".price-range-wrapper .close").live("click", function(){
		$(".price-range-wrapper").hide();
		$(".show-price-range").show();
	});
	
	$(".show-price-range").live("click", function(){
		$("#price_range_wrapper").toggleClass("hide");
	});
	
	$(".show-advanced-search").live("click", function(){
		$("#advanced_search").toggleClass("hide");
	});
	
	$("#advanced_search #cancel_advanced_search").live("click", function(){
		$("#advanced_search").addClass("hide");
	});

	$("#price_range_wrapper #close_price_ranges").live("click", function(){
		$("#price_range_wrapper").addClass("hide");
	});
		
	$(".show-all-phones").live("click", function(){
		brand = "";
		search_term = "";
		$("#search_term").val("");
		reset_price_range();
		reset_advanced_search();
		
		$(".sort-phones-by a").removeClass("disabled");
		$(".sort-phones-by a:nth-child(1)").addClass("disabled");
		sort_by = $(".sort-phones-by a:nth-child(1)").attr("id");
		
		from = 0;
		size = 16;
		
		search("phones", get_params());
	});
	
	reset_price_range();
	
	$("#search_term").live("keyup", function(){
		search_term = $(this).val();
		from = 0;
		size = 16;
		search("phones", get_params())
	});
	
	$(".main-brands-list li a").live("click", function(){
		brand = $(this).html();
		search_term = "";
		reset_price_range();
		from = 0;
		size = 16;

		search("phones", get_params());
	});
	
	$("#apply_prices").live("click", function(event){
		event.preventDefault();
		from = 0;
		size = 16;
		search("phones", get_params());
	});
	
	$("#apply_advanced_search").live("click", function(){
		event.preventDefault();
		from = 0;
		size = 16;
		search("phones", get_params());
	});
	
	$(".sort-phones-by a").live("click", function(){
		$(".sort-phones-by a").removeClass("disabled");
		$(this).addClass("disabled");
		sort_by = $(this).attr("id");
		from = 0;
		size = 16;
		search("phones", get_params());
	});
	
	
	$(window).scroll(function(){
		var has_more_elements = $(".no-more-phones").length === 0;
		if($(window).scrollTop() + $(window).height() == $(document).height() && has_more_elements){
			from += size;
			search("phones", get_params());
		}
	});
	
	search("phones", get_params());
    
    // reviews
    $(".like-phone").live("click", function(event){
    	var review_container = $(this).parent().parent();
    	var id = $(this).attr("data-phone-id");
    	$.ajax({
            url: '/reviews/create_phone_review',
            type: 'POST',
            data: { phone_id : id, like : true },
            beforeSend: function(xhr){
            	review_container.html("<img src='/loading.gif' width='16px' height='16px' />");
            },
            success: function (data, textStatus, xhr) {},
            error: function (xhr, textStatus, errorThrown) { console.log(errorThrown.toString()) },
            complete: function (xhr, textStatus) {}
        });
    });
    
    $(".unlike-phone").live("click", function(event){
    	var review_container = $(this).parent().parent();
    	var id = $(this).attr("data-phone-id");
    	$.ajax({
            url: '/reviews/create_phone_review',
            type: 'POST',
            data: { phone_id : id, unlike : true },
            beforeSend: function(xhr){
            	review_container.html("<img src='/loading.gif' style='width: 16px; height: 16px; clear: both;' />");            	
            },
            success: function (data, textStatus, xhr) {},
            error: function (xhr, textStatus, errorThrown) { console.log(errorThrown.toString()) },
            complete: function (xhr, textStatus) {}
        });
    });
    
    //phone popup tabs
    $('#tabsPhoneMain a').live("click", function (e) {
		e.preventDefault();
	    $(this).tab('show');
	});

	// phones#show
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
	
	$("form#new_comment").submit(function(){
		$(this).append("<img src='/loading.gif' style='width: 16px; height: 16px; clear: both;' id='loading_add_comment' />");
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
	
	// reviews
    $(".like-phone").live("click", function(event){
    	var review_container = $(this).parent().parent();
    	var id = $(this).attr("data-phone-id");
    	$.ajax({
            url: '/reviews/create_phone_review',
            type: 'POST',
            data: { phone_id : id, like : true },
            beforeSend: function(xhr){
            	review_container.html("<img src='/loading.gif' width='16px' height='16px' />");
            },
            success: function (data, textStatus, xhr) {},
            error: function (xhr, textStatus, errorThrown) { console.log(errorThrown.toString()) },
            complete: function (xhr, textStatus) {}
        });
    });
    
    $(".unlike-phone").live("click", function(event){
    	var review_container = $(this).parent().parent();
    	var id = $(this).attr("data-phone-id");
    	$.ajax({
            url: '/reviews/create_phone_review',
            type: 'POST',
            data: { phone_id : id, unlike : true },
            beforeSend: function(xhr){
            	review_container.html("<img src='/loading.gif' style='width: 16px; height: 16px; clear: both;' />");            	
            },
            success: function (data, textStatus, xhr) {},
            error: function (xhr, textStatus, errorThrown) { console.log(errorThrown.toString()) },
            complete: function (xhr, textStatus) {}
        });
    });
	
});