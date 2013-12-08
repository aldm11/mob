$(document).ready(function(){	
	//defaults
	$.ajaxSetup ({  
        cache: false
    }); 
	
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
    
    $(".modal-backdrop").live("click", function(event){
		$(".modal").remove();
	});


	//rails callbacks
    $("#login_form").bind("ajax:before", function(xhr, status, error) {
		$("#login_form .login-btn").after("<div id = 'loading_login' class='pull-right'><img src = '/loading.gif' width = '24px' height = '24px' /></div>");
    });
    
    $("#login_form").bind("ajax:complete", function(xhr, status, error) {
    	$("#loading_login").hide();
    });

    $("#login_form").bind("ajax:success", function(xhr, status, error) {
		window.location = "/";
    });
    
    $("#login_form").bind("ajax:error", function(xhr, status, error) {
    	if($("#login_form .alert-error").length === 0){
			$("<div class='alert-error'>Pogrešni login podaci</div>").appendTo($("#login_form"));
		}
    });
    
});
