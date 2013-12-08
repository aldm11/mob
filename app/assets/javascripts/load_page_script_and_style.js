var script_filename = "/assets/" + $("body").attr("class").split(" ")[0] + ".js";
var script = $("<script></script>").attr("type", "text/javascript").attr("src", script_filename);
script.insertAfter("script:last");

var style_filename = "/assets/" + $("body").attr("class").split(" ")[0] + ".css";
var style = $("<link>").attr("type", "text/css").attr("rel", "stylesheet").attr("media", "all").attr("href", style_filename);
style.insertAfter("link:last");