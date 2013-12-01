$(document).ready(function(){
	
	$(".disabled").live("click", function(e){
		e.stopImmediatePropagation();
		return false;
	});
	
	$(".number").live("keypress", function(event){
      var charCode = (event.which) ? event.which : event.keyCode;
      if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)){
         return false;
      }
      return true;
    });
});
