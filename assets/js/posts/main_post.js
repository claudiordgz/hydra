function addEvent( obj, type, fn ) {
    if (obj.attachEvent) {
        obj['e' + type + fn] = fn;
        obj[type + fn] = function () {
            obj['e' + type + fn](window.event);
        };
        obj.attachEvent('on' + type, obj[type + fn]);
    } else {
        obj.addEventListener(type, fn, false);
    }
}

function removeEvent( obj, type, fn ) {
    if (obj.detachEvent) {
        obj.detachEvent('on' + type, obj[type + fn]);
        obj[type + fn] = null;
    } else {
        obj.removeEventListener(type, fn, false);
    }
}

function slugify(text)
{
    return text.toString().toLowerCase()
        .replace(/\s+/g, '-')           // Replace spaces with -
        .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
        .replace(/\-\-+/g, '-')         // Replace multiple - with single -
        .replace(/^-+/, '')             // Trim - from start of text
        .replace(/-+$/, '');            // Trim - from end of text
}

document.addEventListener("DOMContentLoaded", function(event) {
    var pageContent = document.getElementsByClassName('post-content')[0];
    var navigationLinks  = document.getElementsByClassName('mdl-navigation')[0];
    var postTitle = document.getElementsByClassName('post-title')[0];
    var navigationTitle = document.getElementsByClassName('mdl-layout-title')[0];
    var className = 'mdl-layout__drawer';
    var drawer = document.getElementsByClassName(className)[0];
    navigationTitle.innerText = postTitle.innerText;
    for (var i = 0, childNode; i <= pageContent.children.length; i ++) {
        childNode = pageContent.children[i];
        if(childNode) {
            if(childNode.tagName == 'H2'){
                var text = slugify(childNode.innerText);
                var aTag = document.createElement('a');
                aTag.setAttribute('name',text);
                pageContent.insertBefore(aTag, childNode);
                var linkToTag = document.createElement('a');
                linkToTag.innerHTML = childNode.innerText;
                linkToTag.className = 'mdl-navigation__link';
                linkToTag.href = '#' + text;
                navigationLinks.appendChild(linkToTag);
                i += 1;
            }
        }
    }
    addEvent(window, 'scroll', function(event) {
        var scrollY = document.body.scrollTop;
        if (scrollY >= 585) {
            drawer.className += ' fixed';
        } else {
            drawer.className = className;
        }
    });
});
