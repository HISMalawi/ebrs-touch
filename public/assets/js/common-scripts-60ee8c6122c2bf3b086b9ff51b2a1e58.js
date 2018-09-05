/*---LEFT BAR ACCORDION----*/

$i(function() {
    $i('#nav-accordion').dcAccordion({
        eventType: 'click',
        autoClose: true,
        saveState: true,
        disableLink: true,
        speed: 'slow',
        showCount: false,
        autoExpand: true,
//        cookie: 'dcjq-accordion-1',
        classExpand: 'dcjq-current-parent'
    });
});

var Script = function () {


//    sidebar dropdown menu auto scrolling

    $i('#sidebar .sub-menu > a').click(function () {
        var o = ($i(this).offset());
        diff = 250 - o.top;
        if(diff>0)
            $i("#sidebar").scrollTo("-="+Math.abs(diff),500);
        else
            $i("#sidebar").scrollTo("+="+Math.abs(diff),500);
    });



//    sidebar toggle

    $i(function() {
        function responsiveView() {
            var wSize = $i(window).width();
            if (wSize <= 768) {
                $i('#container').addClass('sidebar-close');
                $i('#sidebar > ul').hide();
            }

            if (wSize > 768) {
                $i('#container').removeClass('sidebar-close');
                $i('#sidebar > ul').show();
            }
        }
        $i(window).on('load', responsiveView);
        $i(window).on('resize', responsiveView);
    });

    $i('.fa-bars').click(function () {
        if ($i('#sidebar > ul').is(":visible") === true) {
            $i('#main-content').css({
                'margin-left': '0px'
            });
            $i('#sidebar').css({
                'margin-left': '-210px'
            });
            $i('#sidebar > ul').hide();
            $i("#container").addClass("sidebar-closed");
        } else {
            $i('#main-content').css({
                'margin-left': '210px'
            });
            $i('#sidebar > ul').show();
            $i('#sidebar').css({
                'margin-left': '0'
            });
            $i("#container").removeClass("sidebar-closed");
        }
    });

// custom scrollbar
    $i("#sidebar").niceScroll({styler:"fb",cursorcolor:"#4ECDC4", cursorwidth: '3', cursorborderradius: '10px', background: '#404040', spacebarenabled:false, cursorborder: ''});

    $i("html").niceScroll({styler:"fb",cursorcolor:"#4ECDC4", cursorwidth: '6', cursorborderradius: '10px', background: '#404040', spacebarenabled:false,  cursorborder: '', zindex: '1000'});

// widget tools

    $i('.panel .tools .fa-chevron-down').click(function () {
        var el = $i(this).parents(".panel").children(".panel-body");
        if ($i(this).hasClass("fa-chevron-down")) {
            $i(this).removeClass("fa-chevron-down").addClass("fa-chevron-up");
            el.slideUp(200);
        } else {
            $i(this).removeClass("fa-chevron-up").addClass("fa-chevron-down");
            el.slideDown(200);
        }
    });

    $i('.panel .tools .fa-times').click(function () {
        $i(this).parents(".panel").parent().remove();
    });


//    tool tips

    $i('.tooltips').tooltip();

//    popovers
    try{
      $i('.popovers').popover();
    }catch(z){
    }


// custom bar chart

    if ($i(".custom-bar-chart")) {
        $i(".bar").each(function () {
            var i = $i(this).find(".value").html();
            $i(this).find(".value").html("");
            $i(this).find(".value").animate({
                height: i
            }, 2000)
        })
    }


}();
