var search = function(){
	var properties = {
		phones : {
			paging : {
				from : 0,
				size : 16
			},
			url : "/search/search_phones",
			before_send : function(parameters){
				if(parameters["from"] === this.paging["from"] && parameters["size"] === this.paging["size"]){
					$(".phones-grid").html("<div id = 'loading_big'><img src = '/loading.gif' width = '48px' height = '48px' /></div>");
				}
				else {
					$(".phones-grid").append("<div id = 'loading_big'><img src = '/loading.gif' width = '48px' height = '48px' /></div>");
				}
			}
		},
		comments : {
			paging : {
				from : 0,
				size : 10
			},
			url : "/comments/show_next_page",
			before_send: function(){
				$("#load_more_comments").remove();
				$(".comments").append("<div id = 'loading_big'><img src = '/loading.gif' width = '48px' height = '48px' /></div>");
			}
		},
		offers: {
			paging: {
				from : 0,
				size: 1
			},
			url: "/catalogue/show_next_page",
			before_send: function(){
				$("#load_more_offers").remove();
				$(".offers").append("<div id = 'loading_big'><img src = '/loading.gif' width = '48px' height = '48px' /></div>");
			}
		},
		messages : {
			paging : {
				from : 0,
				size : 10
			}
		},
		phone_offers : {
			paging : {
				from : 0,
				size : 10
			}
		}
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
			parameters["from"] = properites[search_type]["paging"]["from"];
			parameters["size"] = properties[search_type]["paging"]["size"];
		}
		var url = properties[search_type]["url"];
		
		delay(function(){
			$.ajax({
				url : url,
				type : "POST",
				data : parameters,
				beforeSend: function(xhr){
					properties[search_type].before_send(parameters);
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
