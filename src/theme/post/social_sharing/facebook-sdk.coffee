getStyle = (x, styleProp) ->
  if x.currentStyle
    y = x.currentStyle[styleProp]
  else if window.getComputedStyle
    y = document.defaultView.getComputedStyle(x, null).getPropertyValue(styleProp)
  return y

window.feedDialog = (id, caption, picture) ->
  title = undefined
  description = undefined
  div = document.getElementById(id)
  pic = undefined
  cap = if caption then caption else ''
  i = 0
  childNode = undefined
  while i <= div.childNodes.length
    childNode = div.childNodes[i]
    if childNode
      if /mdl-card__supporting-text/.test(childNode.className)
        description = childNode.textContent
      else if /mdl-card__title/.test(childNode.className)
        title = childNode.innerText
        pic = if !picture then getStyle(childNode, 'background-image') else picture
        pic = pic.replace(/^url\(["']?/, '').replace(/["']?\)$/, '')
    i++
  FB.ui {
    method: 'feed'
    name: title
    link: window.location.href
    description: description
    caption: cap
    picture: pic
    display: 'popup'
  }, (response, show_error) ->
    if response and response.post_id
      console.log 'Post was published.'
    else
      console.log 'Post was not published.'
    return
  return

window.fbAsyncInit = ->
  FB.init
    appId: '1597993133788370'
    xfbml: true
    version: 'v2.4'
  return

((d, s, id) ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  if d.getElementById(id)
    return
  js = d.createElement(s)
  js.id = id
  js.src = '//connect.facebook.net/en_US/sdk.js'
  fjs.parentNode.insertBefore js, fjs
  return
) document, 'script', 'facebook-jssdk'
