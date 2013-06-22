$(document).ready(function(){
	$(".disabled").live("click", function(e){
		e.stopImmediatePropagation();
		return false;
	});
});
