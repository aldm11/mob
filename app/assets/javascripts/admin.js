$(document).ready(function(){
	var options = { targetEvent : "click", targetId : "add_phone", values : ["phone_brand", "phone_model"], imagesNumber : 10, fieldId : "phone_flickrimg", fieldName : "phone[flickrimg]" };
	$("#add_phone").flickrimg(options);   
});
