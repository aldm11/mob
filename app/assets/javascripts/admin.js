$(document).ready(function(){	
	var options = { targetEvent : "click", targetId : "add_phone", values : ["phone_brand", "phone_model"], imagesNumber : 10, fieldId : "phone_flickrimg", fieldName : "phone[flickrimg]" };
	$("#add_phone").flickrimg(options);   
	
	$("#phones_search_term").live("keydown", function(event){
		var search_term = $(this).val().toLowerCase();
		delay(function(){
			$("table.phones-list-admin").find("tr").each(function(){
				if($(this).children(":first").is("td")){	
					console.log("prije content");						 
					var content = $(this).children(":first").html().toLowerCase();
					
					if(content.indexOf(search_term) === -1) {
						$(this).hide();
					}
					else $(this).show();
				}
			});
		}, 500);
	});
});
