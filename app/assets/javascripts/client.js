jQuery(function($){
	//example of callbacks for remote link and form, just make regulat html view on action and in works :)
	
	// TODO: use js.erb view in session#create instead of this and move flickrimg elsewhere and remove client.js
	// $("#login_form").bind("ajax:beforeSend", function(event, data, status, xhr) {		
	// });	
// 	
	$("#login_form").bind("ajax:success", function(event, data, status, xhr) {
		window.location = "/"
    });
    
    $("#login_form").bind("ajax:error", function(xhr, status, error) {
		$("<div class='alert-error'>Pogrešni login podaci</div>").appendTo($("#login_form"));
    });
    
    var options = { targetEvent : "click", targetId : "add_phone", values : ["phone_brand", "phone_model"], imagesNumber : 10, fieldId : "phone_flickrimg", fieldName : "phone[flickrimg]" };
	$("#add_phone").flickrimg(options);    
});
