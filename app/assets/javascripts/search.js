$(document).ready(function(){
	var search_form = $("#main_search_form");
	var min_price = 50;
	var max_price = 1000;
	
	search_form.live("submit", function(){
		$(".phones-grid").html("<img src = 'loading.gif' width = '48px' height = '48px' />");
		$(".phones-grid").css({"text-align" : "center", "padding-top" : "100px"});
	});
	
	var delay = (function(){
	  var timer = 0;
	  return function(callback, ms){
	    clearTimeout (timer);
	    timer = setTimeout(callback, ms);
	  };
	})();
	
	var submit_search_form = function(){
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
		submit_search_form();
	});
	
	$(".main-brands-list li a").live("click", function(){
		$("#brand").val($(this).html());
		submit_search_form();
	});
	
	$("#apply_prices").live("click", function(){
		submit_search_form();
	});
	
	$(".sort-phones-by a").live("click", function(){
		$(".sort-phones-by a").removeClass("disabled");
		$(this).addClass("disabled");
		$("#sort_by").val($(this).attr("id"));
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
});
