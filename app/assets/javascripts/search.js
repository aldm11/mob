$(document).ready(function(){
	var search_form = $("#main_search_form");
	var min_price = 50;
	var max_price = 1000;
	
	var from = 0;
	var size = 16;
	
	search_form.live("submit", function(){
		if(from === 0 && size === 16){
			$(".phones-grid").html("<div id = 'main_loading_phones'><img src = 'loading.gif' width = '48px' height = '48px' /></div>");
		}
		else {
			$(".phones-grid").append("<div id = 'main_loading_phones'><img src = 'loading.gif' width = '48px' height = '48px' /></div>");
		}
	});
	
	var delay = (function(){
	  var timer = 0;
	  return function(callback, ms){
	    clearTimeout (timer);
	    timer = setTimeout(callback, ms);
	  };
	})();
	
	var submit_search_form = function(){
		$("#from").val(from);
		$("#size").val(size);
		delay(function(){ search_form.submit(); }, 500 );
	};
	
	$(".price-from-text").html(min_price);
	$(".price-to-text").html(max_price);
	$("#price_from").val(min_price);
	$("#price_to").val(max_price);
	$("#sort_by").val("date");
	
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
	
	$("#search_term").live("keyup", function(){
		$("#sort_by").val("relevance");
		from = 0;
		size = 16;
		submit_search_form();
	});
	
	$(".main-brands-list li a").live("click", function(){
		$("#brand").val($(this).html());
		from = 0;
		size = 16;
		submit_search_form();
	});
	
	$("#apply_prices").live("click", function(){
		from = 0;
		size = 16;
		submit_search_form();
	});
	
	$(".sort-phones-by a").live("click", function(){
		$(".sort-phones-by a").removeClass("disabled");
		$(this).addClass("disabled");
		$("#sort_by").val($(this).attr("id"));
		from = 0;
		size = 16;
		submit_search_form();
	});
	
		
	$(".price-range-wrapper .close").live("click", function(){
		$(".price-range-wrapper").hide();
		$(".show-price-range").parent().show();
	});
	
	$(".show-price-range").live("click", function(){
		$(this).parent().hide();
		$(".price-range-wrapper").show();
	});
	
	
	$(window).scroll(function(){
		var has_more_elements = $(".no-more-phones").length === 0;
		if($(window).scrollTop() + $(window).height() == $(document).height() && has_more_elements){
			from += size;
			size += size;
			submit_search_form();
		}
	});
	
	// TEMPORARY HACK, RESOLVE THIS USING PALOMA GEM OR ELSE
	if(window.location.toString() === "http://localhost:3000/"){
		submit_search_form();
	}
});
