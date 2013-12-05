$(document).ready(function(){
	
	$(".add-comment-main").live("mouseover", function(){
		$(this).tooltip("show");
	});
	//reviewer
    $(".reviewer > span").live("mouseover", function () {
        $(this).css({ cursor: "pointer" });

        $(this).parent().children().each(function () {
            $(this).css({ color: "#000" });
        });

        $(this).prevAll().each(function () {
            $(this).css({ color:"orange" });
        });
        $(this).css({ color: "orange"});

    });

    $(".reviewer").live("mouseleave", function () {
        $(this).children().each(function () {
            $(this).css({ color: "#000" });
        });
    });
    
    $(".reviewer span").live("click", function(){
    	var feedback = ($(this).prevAll().length + 1).toString();
    	var id = $(this).parent().attr("id");
    	
    	var wrapper = $(this).parent().parent();
    	
    	$.ajax({
            url: '/reviews/create_phone_review',
            type: 'POST',
            data: { phone_id : id, review : feedback },
            success: function (data, textStatus, xhr) {},
            error: function (xhr, textStatus, errorThrown) { console.log(errorThrown.toString()) },
            complete: function (xhr, textStatus) {}
        });
    });
    
    //phone popup tabs
    $('#tabsPhoneMain a').live("click", function (e) {
		e.preventDefault();
	    $(this).tab('show');
	});
	
	
	
});
