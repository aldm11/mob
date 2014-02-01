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
    
    String.prototype.interpolate = function(vars){
    	var left_border = '{';
    	var right_border = '}';
    	function loop(string_rest, new_string){
    		if(!string_rest) return new_string;
    		else {
    			if(string_rest[0] === left_border){
    				var right_border_index = string_rest.indexOf("}");
    				var var_name = string_rest.substring(1, right_border_index);
    				if(var_name[0] === "'"){
    					var_name = var_name.substring(1);
    				}
    				if(var_name[var_name.length-1] === "'"){
    					var_name = var_name.substring(0, var_name.length - 1);
    				}
    				var var_value = vars[var_name];
    				return loop(string_rest.substring(right_border_index+1), new_string + var_value);
    			}
    			else {
    				return loop(string_rest.substring(1), new_string + string_rest[0]);
    			}
    		}
    	}
    	
    	return loop(this, "");
    }
    
    Window.prototype.delay = (function(){
	  var timer = 0;
	  return function(callback, ms){
	    window.clearTimeout (timer);
	    timer = window.setTimeout(callback, ms);
	  };
	})();
    
});
