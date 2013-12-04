$(document).ready(function(){
	var min_price = 50,
	    max_price = 1000;
	
	var search_term = "", 
	    brand = "", 
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
	
	var get_params =  function(){
	   var params = {
			"search_term" : search_term,
			"sort_by" : sort_by,
			"brand" : brand,
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
		$(".show-price-range").show();
	});
	
	$(".show-price-range").live("click", function(){
		$(this).hide();
		$(".price-range-wrapper").show();
	});
	
	$(".show-all-phones").live("click", function(){
		brand = "";
		search_term = "";
		$("#search_term").val("");
		reset_price_range();
		
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
	
	$("#apply_prices").live("click", function(){
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
		if(window.location.toString() === "http://localhost:3000/"){
			var has_more_elements = $(".no-more-phones").length === 0;
			if($(window).scrollTop() + $(window).height() == $(document).height() && has_more_elements){
				from += size;
				search("phones", get_params());
			}
		}
	});
	
	search("phones", get_params());

});