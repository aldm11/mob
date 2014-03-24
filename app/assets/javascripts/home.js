$(document).ready(function(){
	
	//carousel
	// var carousel = function(){
	// }();
	
	var interval = null;
	
	$(".slider").on("click", ".slider-navigation", function(event){	
		clearInterval(interval);
			
		var navigation_type = $(this).attr("data-slide-to");		
		var selected_item = $(".slider").find(".slider-item.active");
		
		var target_item  = null;
		if(navigation_type == "next"){	
			target_item = selected_item.next(".slider-item");
			if(target_item.length === 0) target_item = $(".slider").find(".slider-item:first");
			
		}
		else if(navigation_type == "prev"){	
			target_item = selected_item.prev(".slider-item");
			if(target_item.length === 0) target_item = $(".slider").find(".slider-item:last");
		}
		
		selected_item.fadeOut(1000, function(){
			selected_item.removeClass("active");
			selected_item.removeAttr("style");
			
			target_item.fadeIn(1000, function(){
				target_item.addClass("active");
				target_item.removeAttr("style");
			});
		});	
		
		interval = setInterval( function(){
			$(".slider-navigation.right").click();	
		}, 7000);
	});
	
	interval = setInterval( function(){
		$(".slider-navigation.right").click();	
	}, 7000);
	
});
