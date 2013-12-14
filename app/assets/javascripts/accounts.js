$(document).ready(function(){
	$(".remove-property").bind("ajax:before", function(xhr, status, error) {
		
    });

    $(".remove-property").bind("ajax:success", function(event, data, status, xhr) {
    	console.log(data);
		var values_html = "";
		
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
    	alert($(this).prev().html()+" "+field_class+" "+$("#"+field_class).val());
    	remove_form.submit();
    });
});
