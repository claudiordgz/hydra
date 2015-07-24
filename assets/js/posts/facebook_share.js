window.fbAsyncInit = function() {
    FB.init({
        appId      : '1597993133788370',
        xfbml      : true,
        version    : 'v2.4'
    });
};

(function(d, s, id){
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {return;}
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));

function getStyle(x, styleProp) {
    if (x.currentStyle) var y = x.currentStyle[styleProp];
    else if (window.getComputedStyle) var y = document.defaultView.getComputedStyle(x, null).getPropertyValue(styleProp);
    return y;
}

function feedDialog(id, caption, picture) {
    var title, description;
    var div = document.getElementById(id);
    var pic;
    var cap = caption ? caption : '';
    for (var i = 0, childNode; i <= div.childNodes.length; i ++) {
        childNode = div.childNodes[i];
        if(childNode) {
            if (/mdl-card__supporting-text/.test(childNode.className)) {
                description = childNode.textContent;
            } else if(/mdl-card__title/.test(childNode.className)) {
                title = childNode.innerText;
                pic = !picture ? getStyle(childNode, 'background-image') : picture;
                pic = pic.replace(/^url\(["']?/, '').replace(/["']?\)$/, '');
            }
        }
    }
    FB.ui(
        {
            method: 'feed',
            name: title,
            link: window.location.href,
            description: description,
            caption: cap,
            picture: pic,
            display: 'popup'
        },
        function(response, show_error) {
            if (response && response.post_id) {
                console.log('Post was published.');
            } else {
                console.log('Post was not published.');
            }
        }
    );
}
