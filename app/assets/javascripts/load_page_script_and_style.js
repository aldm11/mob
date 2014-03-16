var script_name = $("body").attr("class").split(" ")[0];
script_name = script_name.split(".")[0];
var script_filename = "/assets/" + script_name + ".js";
var script = $("<script></script>").attr("type", "text/javascript").attr("src", script_filename);
script.insertAfter("script:last");

var style_name = $("body").attr("class").split(" ")[0];
style_name = style_name.split(".")[0];
var style_filename = "/assets/" + style_name + ".css";
var style = $("<link>").attr("type", "text/css").attr("rel", "stylesheet").attr("media", "all").attr("href", style_filename);
style.insertAfter("link:last");