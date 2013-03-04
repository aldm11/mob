jQuery(function($){
	//example of callbacks for remote link and form, just make regulat html view on action and in works :)
	$("#login_form").bind("ajax:beforeSend", function(event, data, status, xhr) {		
	});	
	
	$("#login_form").bind("ajax:success", function(event, data, status, xhr) {
      	window.location = "/"
    });
    
    $("#login_form").bind("ajax:error", function(xhr, status, error) {
		$("<div class='alert-error'>Pogrešni login podaci</div>").appendTo($("#login_form"));
    });
    
    
});
