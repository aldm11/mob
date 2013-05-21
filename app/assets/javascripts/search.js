var search = function(){
	var paging = {
		"phones" : {
			"from" : 0,
			"size" : 16
		},
		"messages" : {
			"from" : 0,
			"size" : 10
		},
		"phone_offers" : {
			"from" : 0,
			"size" : 10
		}	
	}
	
	var urls = {
		"phones" : "search/search_phones",
		"messages" : "",
		"phone_offers" : ""
	}
	
	var delay = (function(){
	  var timer = 0;
	  return function(callback, ms){
	    window.clearTimeout (timer);
	    timer = window.setTimeout(callback, ms);
	  };
	})();
	
	return function(search_type, params){
		var parameters = params;
		if (parameters["from"] === undefined){
			parameters["from"] = paging[search_type]["from"];
			parameters["size"] = paging[search_type]["size"];
		}
		
		var url = urls[search_type];
						
		delay(function(){
			$.ajax({
				url : url,
				type : "POST",
				data : parameters,
				beforeSend: function(xhr){
					if(parameters["from"] === 0 && parameters["size"] === 16){
						$(".phones-grid").html("<div id = 'main_loading_phones'><img src = 'loading.gif' width = '48px' height = '48px' /></div>");
					}
					else {
						$(".phones-grid").append("<div id = 'main_loading_phones'><img src = 'loading.gif' width = '48px' height = '48px' /></div>");
					}
				},
	            success: function (data, textStatus, xhr) {
	            	console.log("Search for " + search_type + " executed");
	            },
	            error: function (xhr, textStatus, errorThrown) { console.log("Error during search for " + search_type + " " + errorThrown.toString()) },
	            complete: function (xhr, textStatus) {}
			});
		}, 500);
	};
}();
