$(document).ready(function(){
	//phone popovers in catalogue
	$(".catalogue-phone-title").each(function(){
		$(this).live("click", function(){
			event.preventDefault();
		});
		//$(this).popover({html: true, delay: 1000, trigger: "hover"});
		
		var showPopover = function () {
		    $(this).popover('show');
		};
		
		var hidePopover = function () {
		    $(this).popover('hide');
		};
		
		var togglePopover = function () {
			$(this).popover('toggle');
		};
		
		$(this).popover({
		    trigger: 'manual',
		    html: true,
		    delay: 1000
		}).click(showPopover);//TODO: uncomment this.hover(showPopover, hidePopover);
	});

	$(".prices-history").each(function(){
		$(this).live("click", function(){
			event.preventDefault();
		});
		$(this).popover({html: true, delay: 0, trigger: "click"});
	});
		
	$(".prices-from-others").each(function(){
		$(this).live("click", function(){
			event.preventDefault();
		});
		$(this).popover({html: true, delay: 0, trigger: "click"});
	});
	
	$(".catalogue-phone-title").live("mouseleave", function(){
		$(this).popover("hide");
	});
	
	$(".catalogue-item-main").live("mouseover", function(){
		$(this).find(".show-on-hover").css({"visibility" : "visible"});	
	});

	$(".catalogue-item-main").live("mouseleave", function(){
		$(this).find(".show-on-hover").css({"visibility" : "hidden"});
	});
	//end of phone popovers
	
	//TODO: find better way to handle this clicks on reset button
	$(".cancel-catalogue-save").live("click", function(){
		//TODO: remove typeahead dropdown menu
		$(".save-catalogue-item").modal("hide");
		$(".save-catalogue-item").remove();
	});
	
	$("#saveCatalogueItem").live("submit", function(){
		if($("#phone_name").val().length < 3 || $("#price").val().length < 2){
			$(".modal-footer").html("<p class='text-error'>Niste unijeli telefon ili cijenu !</p>");
			return false;
		}
		return true;
	});
	
	$("#catalogue_search_term").live("keydown", function(event){
		var term = $(this).val().toLowerCase();
		var terms = term.split(" ");
		
		$(".catalogue-item-main").each(function(){
			var phone_name = $(this).find(".catalogue-phone-title").html().toLowerCase();
			var show = false;
			for(var i = 0; i < terms.length; i++){
				if(phone_name.indexOf(terms[i]) !== -1){
					show = true;
					break;
				}
			}
			if(show) $(this).show();
			else $(this).hide();
		});
	});
	
});
