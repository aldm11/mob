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
    	$(this).html() === "Add" ? $(this).html("Cancel") : $(this).html("Add");
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
    
});
