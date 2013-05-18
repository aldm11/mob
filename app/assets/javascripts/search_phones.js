$(document).ready(function(){
	var search_form = $("#main_search_form");
	var min_price = 50;
	var max_price = 1000;
	
	var from = 0;
	var size = 16;
	
	$(".price-from-text").html(min_price);
	$(".price-to-text").html(max_price);
	$("#price_from").val(min_price);
	$("#price_to").val(max_price);
	$("#sort_by").val("date");
	
	var get_params =  function(){
	   var params = {
			"search_term" : $("#search_term").val(),
			"sort_by" : $("#sort_by").val(),
			"brand" : $("#brand").val(),
			"price_from" : $("#price_from").val(),
			"price_to" : $("#price_to").val(),
			"from" : from,
			"size" : size
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
		$(".show-price-range").parent().show();
	});
	
	$(".show-price-range").live("click", function(){
		$(this).parent().hide();
		$(".price-range-wrapper").show();
	});
	
	$("#search_term").live("keyup", function(){
		// $("#sort_by").val("relevance");
		// from = 0;
		// size = 16;
		// submit_search_form();
		
		$("#sort_by").val("relevance");
		search("phones", get_params())
	});
	
	$(".main-brands-list li a").live("click", function(){
		$("#brand").val($(this).html());
		$("#search_term").val("");
		search("phones", get_params());
	});
	
	$("#apply_prices").live("click", function(){
		search("phones", get_params());
	});
	
	$(".sort-phones-by a").live("click", function(){
		$(".sort-phones-by a").removeClass("disabled");
		$(this).addClass("disabled");
		$("#sort_by").val($(this).attr("id"));
		
		search("phones", get_params());
	});
	
	
	$(window).scroll(function(){
		var has_more_elements = $(".no-more-phones").length === 0;
		if($(window).scrollTop() + $(window).height() == $(document).height() && has_more_elements){
			from += size;
			search("phones", get_params());
		}
	});
	
	// TEMPORARY HACK, RESOLVE THIS USING PALOMA GEM OR ELSE
	if(window.location.toString() === "http://localhost:3000/"){
		search("phones", get_params());
	}
});
