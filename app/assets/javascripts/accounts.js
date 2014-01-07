$(document).ready(function(){
	//removing properties
	$(".remove-property").bind("ajax:before", function(xhr, status, error) {
		$(this).closest("tr").find("values").html("<div id = 'loading_big' class='loading center'><img src = '/loading.gif' width = '24px' height = '24px' /></div>");
    });

    $(".remove-property").bind("ajax:success", function(event, data, status, xhr) {
		updateCallback(data)	
    });

    $(".remove-property").bind("ajax:error", function(xhr, status, error) {
    	console.log(status+ " "+error);
		var message = $("<div class='text-error'></div>").html(error.message);
		var cell = $(this).parents("td:first").append(message);
    });
    
    $("a.remove-property").live("click", function(event){
    	event.preventDefault();
    	var remove_form = $(this).closest("td").find("form");
    	var field_class = $(this).attr("data-property")+"_"+"remove";
    	$("#"+field_class).val($(this).prev().html());
    	remove_form.submit();
    });
    
    
    //adding properties
    $("a.toggle-property").live("click", function(){
    	event.preventDefault();    	
    	$(this).closest("td").find("form").toggleClass("hidden");
    	$(this).closest("td").find("a.add-property").toggleClass("hidden");
    	// $(this).html() === "Add" ? $(this).html("Cancel") : $(this).html("Add");
    	$(this).toggleClass("icon-edit").toggleClass("icon-remove");
    }); 
    
    
    $("a.add-property").live("click", function(event){
    	$(this).closest("td").find("form").submit();
    });
    
    $("form.add-property").bind("ajax:before", function(xhr, status, error) {
    	$(this).closest("tr").find("values").html("<div id = 'loading_big' class='loading center'><img src = '/loading.gif' width = '24px' height = '24px' /></div>");
    });

    $("form.add-property").bind("ajax:success", function(event, data, status, xhr) {
		updateCallback(data)
		$(this).find("input[type=text]").val("");
    });

    $("form.add-property").bind("ajax:error", function(xhr, status, error) {
		var message = $("<div></div>").attr("class", "text-error").html(status.responseText);
		$(this).closest("td").append(message);
		
		setTimeout(function(){message.fadeOut(1500, function(){})}, 1500);
    });
        
    function updateCallback(data){
    	for(var attr in data.attributes){
    		var attribute_values_html = "";
    		var values = data.attributes[attr];
    		
    		if(typeof values === "string"){
				attribute_values_html = values;
			}
			else {
				for(var i = 0; i < values.length; i++){
					var html_template = '<div class="label label-info">' +
											'<span>{val}</span>' +
											'<a href="#" class="icon-remove remove-property" data-property="{attr}"></a>' +
								 		'</div>';
	
					attribute_values_html += html_template.interpolate({attr: attr, val: values[i]});
				}
			}	
			$("."+[attr, "info"].join("-")).find(".values").html(attribute_values_html);
			
			var confirm_message_html = $("<div><div>").attr("id", [attr, "message"].join("_")).attr("class", "text-success").html(data.message);
			$("."+[attr, "info"].join("-")).find(".values").append(confirm_message_html);			
			setTimeout(function(){ confirm_message_html.fadeOut(2000, function(){})}, 1500);
		}	
    }
    
    //password change
	$("form.change-password").bind("ajax:before", function(xhr, status, error) {
		$(this).find("input[type=submit]").attr("disabled", "disabled");
		$(this).append("<div id = 'loading_big' class='loading center'><img src = '/loading.gif' width = '24px' height = '24px' /></div>");
    });

    $("form.change-password").bind("ajax:success", function(event, data, status, xhr) {
    	$("#loading_big").remove();
		$(this).find("input[type=submit]").removeAttr("disabled");
		$(this).find("input[type=password]").val("");
		
		var confirm_message = $("<div></div>").attr("class", "text-success").html(data.message);
		$(this).append(confirm_message);
		setTimeout(function(){confirm_message.fadeOut(2000, function(){})}, 1500);
    });

    $("form.change-password").bind("ajax:error", function(xhr, status, error) {
    	$("#loading_big").remove();
    	$(this).find("input[type=submit]").removeAttr("disabled");
				
		var error_message = $("<div></div>").attr("class", "text-error").html(status.responseText);
		$(this).append(error_message);
		setTimeout(function(){error_message.fadeOut(2000, function(){})}, 1500);
    });
    
    //avatar upload
    $("a.change-avatar").live("click", function(event){
    	$("#avatar").click();
    });
    
    $("img.account-settings-avatar").hover(function(event){
    	$(this).css("opacity", 0.4);
    	$("a.change-avatar").css("opacity", 1);
    	$("a.change-avatar").show();
    }, function(event){
    	if(!$("a.change-avatar").is(":hover")){
    		$(this).css("opacity", 1);
    		$("a.change-avatar").hide();
    	}
    	
    });
    
    var upload_message = $("<div style='width: 100%; height: 100%; text-align: center; vertical-align: center;'><img src = '/loading.gif' width = '24px' height = '24px' /></div>");
    var max_file_size = 4000000;
    $('#avatar').fileupload({
        dataType: 'json',
        done: function (e, data) {
            $("img.account-settings-avatar").attr("src", data._response.result.avatar);
            upload_message.remove();
            $("img.account-settings-avatar").show();
        },
        add: function (e, data) {
        	if(data.files[0].size > max_file_size){
        		showError("Prevelik fajl. Maksimalna velicina avatara je " + (max_file_size/1000000) + " MB");	
        	}
        	else {
	            // Automatically upload the file once it is added to the queue
	            var jqXHR = data.submit();
	            $(".avatar-wrapper").width($("img.account-settings-avatar").width());
	            $(".avatar-wrapper").height($("img.account-settings-avatar").height());
	            $("img.account-settings-avatar").hide();
	            $(".avatar-wrapper").append(upload_message);
	        }
        },

        progress: function(e, data){

            // // Calculate the completion percentage of the upload
            // var progress = parseInt(data.loaded / data.total * 100, 10);
// 
            // // Update the hidden input field and trigger a change
            // // so that the jQuery knob plugin knows to update the dial
            // data.context.find('input').val(progress).change();
// 
            // if(progress == 100){
                // data.context.removeClass('working');
            // }
        },

        fail:function(e, data){
        	upload_message.remove();
        	$("img.account-settings-avatar").show();
        	showError(data._response.jqXHR.responseText);
        }
    });
    
    function showError(error_message){
	    var error_message = $("<small></small>").addClass("text-error").html(error_message);
    	error_message.insertAfter(".avatar-wrapper");
    	setTimeout(function(){ error_message.fadeOut(1500, function(){}); }, 3000);
    }
    
});
