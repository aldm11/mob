var js_vars = function(){
	return {
		set : function(name, value){
			var data = {};
			data["vars"] = {};
			data["vars"][name] = value;
			$.ajax({
				url: "/set_js_vars",
				dataType: "json",
				type: "POST",
				data: data,
				beforeSend: function(xhr){},
	            success: function (data, textStatus, xhr) {
	            	return data;
	            },
	            error: function (xhr, textStatus, errorThrown) { 
	            	console.log("Error during setting var " + name + " to " + value);
	            	return null; 
	            },
	            complete: function (xhr, textStatus) {}
			});
		},
		get: function(name){
			var result = null;
			$.ajax({
				url: "/get_js_var",
				dataType: "json",
				type: "POST",
				async: false,
				data: {"name" : name},
				beforeSend: function(xhr){},
	            success: function (data, textStatus, xhr) {
	            	result = data;
	            },
	            error: function (xhr, textStatus, errorThrown) { 
	            	console.log("Error during setting var " + name + " to " + value);
	            	return null; 
	            },
	            complete: function (xhr, textStatus) {}
			});
			return result;
		}
	}
}();
