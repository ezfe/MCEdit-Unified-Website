function setURL(id, url) {
    fetch(`/setCommentURL/${id}`, {
        method: 'post',
        body: JSON.stringify({ url: url }),
        credentials: 'same-origin',
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
    }).then(res => {
        console.log(res)
    })
}

function pageTrigger() {
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
}