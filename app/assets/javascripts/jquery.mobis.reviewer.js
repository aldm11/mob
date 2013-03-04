$(function ($) {

    var settings = "";
    var reviewSummary = "";

    function roundVal(val) {
        var dec = 2;
        var result = Math.round(val * Math.pow(10, dec)) / Math.pow(10, dec);
        return result;
    }

    function getJsonValue(source, key, value) {
        var result = 0;
        $.each(source, function (i, item) {
            if (item[key] == value) {
                result = item.AverageReview;
            }
        });
        return result;
    }

    $.fn.reviewer = function (options) {
        settings = $.extend({
            starFontSize: "12pt",
            starColorNormal: "#000",
            starColorHovered: "#000",
            distanceBetweenStars: 3,
            maxFeedback: 5,
            type: "product",
            x: 0,
            y: 0
        }, options);

        var reviews = "";
        $.ajax({
            url: '/Product/GetReviews',
            type: 'GET',
            dataType: 'json',
            async: false,
            data: { type: settings.type },
            success: function (data, textStatus, xhr) {
                reviews = data;
            },
            error: function (xhr, textStatus, errorThrown) {},
            complete: function (xhr, textStatus) {}
        });


        $(this).each(function () {
            var id = $(this).attr("id");
            var selector = $(this);

            var xi = settings.x == 0 ? selector.offset().left + selector.width() / 2 - 50 : selector.offset().left + settings.x;
            var yi = settings.y == 0 ? selector.offset().top + selector.height() - 7 : selector.offset().top + settings.y + 3;

            var key = settings.type == "product" ? "ProductId" : "CatalogueId";
            var value = getJsonValue(reviews, key, id);
            var averageReview = value == 0 ? 0 : roundVal(value);
            $("<span class='average-review' title='Prosječna ocjena artikla'>" + averageReview + "</span>").css({ position: "absolute", left: xi, top: yi, color: "#FE2E2E", 'font-weight': 'bold' }).appendTo(selector);

            var htmlContainer = $("<div class='reviewer' title='Rate article'></div>");
            var i = 0;
            for (i = 0; i < settings.maxFeedback; i++) {
                $("<div></div>").css({ float: "left", 'font-size': settings.starFontSize, 'padding-right': settings.distanceBetweenStars + "px",
                    color: settings.starColorNormal
                }).html("&#9734;").appendTo(htmlContainer);
            }

            var x = settings.x == 0 ? $(this).offset().left + $(this).width() / 2 - 20 : $(this).offset().left + settings.x + 30;
            var y = settings.y == 0 ? $(this).offset().top + $(this).height() - 10 : $(this).offset().top + settings.y;

            $(this).css({ 'padding-bottom:': '10px' });
            htmlContainer.css({ position: "absolute", left: x, top: y }).appendTo($(this));

        });


        $(".reviewer > div").mouseover(function () {
            $(this).css({ cursor: "pointer" });

            $(this).parent().children().each(function () {
                $(this).css({ color: settings.starColorNormal });
            });

            $(this).prevAll().each(function () {
                $(this).css({ color: settings.starColorHovered });
            });
            $(this).css({ color: settings.starColorHovered });

        });

        $(".reviewer").mouseleave(function () {
            $(this).children().each(function () {
                $(this).css({ color: settings.starColorNormal });
            });
        });


        $(".reviewer > div").click(function () {
            var feedck = ($(this).prevAll().length + 1).toString();

            var ide = $(this).parent().parent().attr("id");

            var action = "/Product/AddReview";
            if (settings.type == "catalogue") {
                action = "/Catalogue/AddReview";
            }

            $.post(action, { id: ide, feedback: feedck }, function (result) {
                reviews = result;
                var key = settings.type == "product" ? "ProductId" : "CatalogueId";
                var averageReview = roundVal(getJsonValue(reviews, key, ide));
                $("#" + ide).children("span").html(averageReview);
                $('<span class="review_added">Uspješno ste ocijenili artikal</span>').appendTo("body").dialog({
                    modal: true,
                    buttons: { "U redu": function () { $(this).dialog("close"); } },
                    title: "Informacija",
                    open: function (event, ui) { $(".ui-dialog-titlebar-close").hide(); }
                });

            });

        });

    };

})(jQuery)