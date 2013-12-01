jQuery(function($){
	$.fn.flickrimg = function(options){
		var default_settings = { imagesNumber: 5, width: 20, height: 20 };
		var settings = $.extend(default_settings, options);
		
		var selector = $(this);      
		
		$.each(settings.values, function(i, item){
			settings.values[i] = "#" + item;
		});
		var values_selector = settings.values.join(", ");
		
		init(selector);
		
		$(values_selector).bind("focusout", function(){
			appendImages();
		});
		
		$(".image").live("click", function(){
			$("#"+settings.fieldId).val($(this).attr("src"));
			selector.val($(this).attr("src"));
		});
		
		selector.live("change", function(){
			var index = $(this).val().lastIndexOf("\\");
        	$("#"+settings.fieldId).val($(this).val().substr(index + 1));
		});
		
		$(".flickrimg-trigger").live("mouseover", function(){
			if($(".images-container").length == 0){
				appendImages();			
			}
		});
		
		function appendImages(){
			var term =  "";
			$.each(settings.values, function(i, item){
				term += $(item).val() + "%20";
			});
			
			var url = "http://api.flickr.com/services/rest/?" +
				        "method=flickr.photos.search&" +
				        "api_key=90485e931f687a9b9c2a66bf58a3861a&" +
				        "text=" + term +
				        "&safe_search=1&" +  // 1 is "safe"
				        "content_type=1&" +  // 1 is "photos only"
				        "sort=relevance&" +  // another good one is "interestingness-desc"
				        "per_page=" + settings.imagesNumber.toString() + "&format=json&nojsoncallback=1";
		
			var html = "";
			$.ajax({
				url : url, 
				type: "GET",
				data: {},
				async: false,
				success: function(result, textStatus, xhr){
					$.each(result.photos.photo, function(j, photo){
						html += '<img src="' + constructImageURL(photo) + '" class=" img-rounded image" />'
					});
				},
				error: function (xhr, textStatus, errorThrown) { alert(textStatus); }
			});
			  
			if($(".images-container").length == 0){
				html = '<div class="dropdown-menu images-container" role="menu" aria-labelledby="dLabel">' + html + '</div>';
				$(".flickrimg").append(html);
			}
			else{
				$(".images-container").html(html);
			}
		};
		
		function init(element){
			if ($("#"+settings.fieldId).length == 0){
				var html = '<input type="hidden" id="' + settings.fieldId + '" name="' + settings.fieldName + '" />';  
				html += '<div class="dropdown flickrimg">' + 
						'<a class="dropdown-toggle flickrimg-trigger" data-toggle="dropdown" href="#">Dropdown trigger</a>' +
						'</div>';
				
				element.after(html);
			}
		}
		
	};
	
	function constructImageURL(photo) {
	  return "http://farm" + photo.farm +
	      ".static.flickr.com/" + photo.server +
	      "/" + photo.id +
	      "_" + photo.secret +
	      "_s.jpg";
	};
	
});
