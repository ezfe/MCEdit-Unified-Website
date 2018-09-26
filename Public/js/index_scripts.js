window.onload = function() {
    var is_OSX = navigator.platform.match(/(Mac)/i);
    var is_Win = (navigator.platform.match(/(Win)/i) && !is_OSX);

    $('.beta-container').hide();

    if (is_OSX) {
        $('#Win-downloads-toplevel').hide();
        $('#Lin-downloads-toplevel').hide();
        $('#OSX-downloads-toplevel').addClass('col-md-offset-4');
        $('.override-platform-specific-downloads-container').show();
    } else if (is_Win) {
        $('#OSX-downloads-toplevel').hide();
        $('#Lin-downloads-toplevel').hide();
        $('#Win-downloads-toplevel').addClass('col-md-offset-4');
        $('.override-platform-specific-downloads-container').show();
    }
    $('.override-platform-specific-downloads').click(function(){
        $('#Win-downloads-toplevel').show();
        $('#Lin-downloads-toplevel').show();
        $('#OSX-downloads-toplevel').show();
        if (is_OSX) {
            $('#OSX-downloads-toplevel').removeClass('col-md-offset-4');
        } else if (is_Win) {
            $('#Win-downloads-toplevel').removeClass('col-md-offset-4');
        }
        $('.beta-container').show();
        $('.override-platform-specific-downloads-container').hide();
        return false;
    });
    
    const alerts = document.getElementsByClassName("site-alert")
    for (var i = 0; i < alerts.length; i++) {
        const alert = alerts[i];
        const alertid = alert.attributes["alertid"].value;
        if (localStorage.getItem(`dismissed-alert-${alertid}`) === "yes") {
            alert.remove();
        }
    }
}
