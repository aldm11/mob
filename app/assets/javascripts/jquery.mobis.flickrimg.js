jQuery(function($){
	$.fn.flickrimg = function(options){
		var default_settings = { imagesNumber: 5, width: 40, height: 20 };
		var settings = $.extend(default_settings, options);
		
		var selector = $(this);      
		
		$.each(settings.values, function(i, item){
			settings.values[i] = "#" + item;
		});
		var values_selector = settings.values.join(", ");
				
		var value_exists = false;
		for(var i = 0; i < settings.values.length; i++){
			if($(settings.values[i]).val().length > 1){
				value_exists = true;
				break;
			}
		}
		init(selector, value_exists);
		if(value_exists) appendImages();	
		$(values_selector).bind("focusout", function(){ appendImages(); });

		
		$(".image").live("click", function(){
			var image_src = $(this).attr("src");
			$("#"+settings.fieldId).val(image_src);
			//selector.val($(this).attr("src"));
			
			var message = $("<div class='confirm-message text-success'>Slika " + image_src + " uspjesno postavljena</div>");
			$(".flickrimg-wrapper").after(message);
			
			setTimeout(function(){
				$(".confirm-message").fadeOut(2000);
			}, 2000);
		});
		
		selector.live("change", function(){
			var index = $(this).val().lastIndexOf("\\");
        	$("#"+settings.fieldId).val($(this).val().substr(index + 1));
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
				beforeSend: function(xhr, settings){
					if($("#loading_flickr_images").length === 0){
						$(".flickrimg").html("<li><div id = 'loading_flickr_images'><img src = '/loading.gif' width = '24px' height = '24px' /></div></li>")
					}
				},
				success: function(result, textStatus, xhr){
					$.each(result.photos.photo, function(j, photo){
						html += '<li><img src="' + constructImageURL(photo) + '" class=" img-rounded image" /></li>'
					});
					
					$(".images-container").html(html);
				},
				error: function (xhr, textStatus, errorThrown) { 
					$("#loading_flickr_images").parent().remove();
					alert(textStatus);
					$(".flickrimg").append("<ul><div class='text-error'>Error while loading images. Please try later.</div></ul>");
				}
			});
		};
		
		function init(element, value_exists){
			if ($("#"+settings.fieldId).length == 0){
				var html = '<input type="hidden" id="' + settings.fieldId + '" name="' + settings.fieldName + '" />';  
				html += '<div class="dropdown flickrimg-wrapper">' + 
						'<a href="#" class="dropdown-toggle flickrimg-toggle" data-toggle="dropdown">Nadji slike</a>' +
						'<ul class="dropdown-menu flickrimg images-container"><li><div class="span12">'
						
				html += value_exists ? '<img src = "/loading.gif" width = "24px" height = "24px" />' : '<small class="text-error">Morate unijeti polja ' + settings.values.join(", ") + '</small>';
						
			    html += '</div></li></ul>' +
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
