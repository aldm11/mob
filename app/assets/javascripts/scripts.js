$(document).ready(function(){
	//defaults
	$.ajaxSetup ({  
        cache: false
    }); 
	//////////
	//common
	$(".number").live("keypress", function(event){
      var charCode = (event.which) ? event.which : event.keyCode;
      if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)){
         return false;
      }
      return true;
    });
    ///////
	
	var options = { targetEvent : "click", targetId : "add_phone", values : ["phone_brand", "phone_model"], imagesNumber : 10, fieldId : "phone_flickrimg", fieldName : "phone[flickrimg]" };
	$("#add_phone").flickrimg(options);
	
	$(".add-comment-main").live("mouseover", function(){
		$(this).tooltip("show");
	});
	//reviewer
    $(".reviewer > span").live("mouseover", function () {
        $(this).css({ cursor: "pointer" });

        $(this).parent().children().each(function () {
            $(this).css({ color: "#000" });
        });

        $(this).prevAll().each(function () {
            $(this).css({ color:"orange" });
        });
        $(this).css({ color: "orange"});

    });

    $(".reviewer").live("mouseleave", function () {
        $(this).children().each(function () {
            $(this).css({ color: "#000" });
        });
    });
    
    $(".reviewer span").live("click", function(){
    	var feedback = ($(this).prevAll().length + 1).toString();
    	var id = $(this).parent().attr("id");
    	
    	var wrapper = $(this).parent().parent();
    	
    	$.ajax({
            url: '/reviews/create_phone_review',
            type: 'POST',
            data: { phone_id : id, review : feedback },
            success: function (data, textStatus, xhr) {
            	wrapper.html(data);
            	$("#reviewAdded").modal();
            	
            	
            },
            error: function (xhr, textStatus, errorThrown) { console.log(errorThrown.toString()) },
            complete: function (xhr, textStatus) {}
        });
    });
    
    //phone popup tabs
    $('#tabsPhoneMain a').live("click", function (e) {
		e.preventDefault();
	    $(this).tab('show');
	});
	

	$(".modal-backdrop").live("click", function(event){
		$(".modal").remove();
	});
	$(".catalogue-phone-title").each(function(){
		$(this).attr("data-title", $(this).parent().next().children(".popover-title").html());
		$(this).attr("data-content", $(this).parent().next().children(".popover-content").html());
		$(this).popover({html: true, delay: 1000, trigger: "hover"});
	});

	$(".prices-history").each(function(){
		$(this).attr("data-title", "Price history");
		$(this).attr("data-content", $(this).parent().parent().parent().next().next().html());
		$(this).popover({html: true, delay: 0, trigger: "click"});
	});
	
	$(".prices-from-others").each(function(){
		$(this).attr("data-title", "Prices from others");
		$(this).attr("data-content", $(this).parent().parent().parent().next().next().next().html());
		$(this).popover({html: true, delay: 0, trigger: "click"});
	});
	
	$(".catalogue-phone-title").mouseleave(function(){
		$(this).popover("hide");
	})
	
	$(".catalogue-item-main").live("mouseover", function(){
		$(this).find(".show-on-hover").css({"visibility" : "visible"});	
	});

	$(".catalogue-item-main").live("mouseleave", function(){
		$(this).find(".show-on-hover").css({"visibility" : "hidden"});
	});
	
	//TODO: find better way to handle this clicks on reset button
	$("button[type='reset']").live("click", function(){
		//TODO: remove typeahead dropdown menu
		$(".save-catalogue-item").modal("hide");
		$(".save-catalogue-item").remove();
	});
	
	$("button[type='reset']").live("click", function(){
		$(".remove-confirm").modal("hide");
		$(".remove-confirm").remove();
	});
	
	$("#saveCatalogueItem").live("submit", function(){
		if($("#phone_name").val().length < 3 || $("#price").val().length < 2){
			$(".modal-footer").html("<p class='text-error'>Please enter valid phone name and price !</p>");
			return false;
		}
		return true;
	});
	
});
