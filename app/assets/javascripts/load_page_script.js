$(document).ready(function(){
	var script_filename = "/assets" + $("body").attr("class").split(" ")[0] + ".js";
	var script = $("<script></script>").attr("type", "text/javascript").attr("src", script_filename);
	script.insertAfter("script:last");
});
