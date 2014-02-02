$(document).ready(function(){	
	var options = { targetEvent : "click", targetId : "add_phone", values : ["phone_brand", "phone_model"], imagesNumber : 10, fieldId : "phone_flickrimg", fieldName : "phone[flickrimg]" };
	$("#add_phone").flickrimg(options);   
	
	var filter_options = {
		type: "all",
		search_term: null
	};
	$("#phones_search_term").live("keydown", function(event){
		var search_term = $(this).val().toLowerCase();
		filter_options.search_term = search_term;
		delay(function(){
			$("table.phones-list-admin tr").each(function(){
				var first_children = $(this).children(":first");
				if(first_children.is("td")){	
					var content = first_children.html().toLowerCase();
					var type = $(this).children(":last").children("input[type=hidden]").val();
					
					if(content.indexOf(search_term) !== -1 && (filter_options.type === "all" || filter_options.type === type)) $(this).show();
					else $(this).hide();
				}
			});
		
		}, 100);	
	});
	
	$(".phones-catalogue-filter a").live("click", function(event){
		var clicked_link = $(this);
		var phones_type = $(this).attr("data-type");
		filter_options.type = phones_type;
				
		if(!$(this).hasClass("disabled")) $(this).addClass("disabled");
		$(this).parent().children("a").each(function(){
			if($(this).html() !== clicked_link.html()) $(this).removeClass("disabled");
		});
		
		$("table.phones-list-admin tr").each(function(){
			
			var last_children = $(this).children(":last");
			if(last_children.is("td")){
				var content = null;
				if(filter_options.search_term !== null) content = $(this).children(":first").html().toLowerCase();
				
				if((filter_options.search_term === null || content.indexOf(filter_options.search_term) !== -1) && (phones_type === "all" || phones_type === last_children.children("input[type=hidden]").val())) $(this).show();
				else $(this).hide();
			}
		});
	});
});
