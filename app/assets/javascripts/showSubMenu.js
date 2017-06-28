
    function showSubMenu(children) {
        $('.parent_menu').hide();
        $('.' + children).show();
        $('.logout').hide();
        $('.back').show();
        $('.back').click(function () {
            $('.child_menu').hide();
            $('.parent_menu').show();
            $('.logout').show();
            $(this).hide();
        });
    }

    /*function hideElements(){
     $('.child_menu').hide();
     }*/

    /*jQuery( document ).ready(function( $ ) {
     $('.child_menu').hide();
     });/
     /* window.setTimeout("hideElements();", 50);*/


