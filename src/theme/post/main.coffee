
app = require "../blog/main"

adsLoaded = ->

addEvent = (obj, type, fn) ->
  if obj.attachEvent
    obj['e' + type + fn] = fn

    obj[type + fn] = ->
      obj['e' + type + fn] window.event
      return

    obj.attachEvent 'on' + type, obj[type + fn]
  else
    obj.addEventListener type, fn, false
  return

removeEvent = (obj, type, fn) ->
  if obj.detachEvent
    obj.detachEvent 'on' + type, obj[type + fn]
    obj[type + fn] = null
  else
    obj.removeEventListener type, fn, false
  return

slugify = (text) ->
  text.toString().toLowerCase().replace(/\s+/g, '-').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '-').replace(/^-+/, '').replace /-+$/, ''
# Trim - from end of text

loadScript = (url, callback) ->
# Adding the script tag to the head as suggested before
  head = document.getElementsByTagName('head')[0]
  script = document.createElement('script')
  script.type = 'text/javascript'
  script.src = url
  # Then bind the event to the callback function.
  # There are several events for cross browser compatibility.
  script.onreadystatechange = callback
  script.onload = callback
  script.async = true
  # Fire the loading
  head.appendChild script
  return


$(window).resize ->
  'use strict'
  if @resizeTO
    clearTimeout @resizeTO
  @resizeTO = setTimeout((->
    $(this).trigger 'resizeEnd'
    return
  ), 500)
  return
$(window).bind 'resizeEnd', ->
  'use strict'
  app.app.refreshIntro()
  return


document.addEventListener 'DOMContentLoaded', (event) ->
  app.app.init()
  pageContent = document.getElementsByClassName('post-content')[0]
  navigationLinks = document.getElementsByClassName('mdl-navigation')[0]
  postTitle = document.getElementsByClassName('post-title')[0]
  navigationTitle = document.getElementsByClassName('mdl-layout-title')[0]
  className = 'mdl-layout__drawer'
  drawer = document.getElementsByClassName(className)[0]
  if navigationTitle.innerText
    navigationTitle.innerText = postTitle.innerText
  else if navigationTitle.innerHTML
    navigationTitle.innerHTML = postTitle.innerHTML
  i = 0
  childNode = undefined
  while i <= pageContent.children.length
    childNode = pageContent.children[i]
    if childNode
      if childNode.tagName == 'H2'
        textToSlugify = if childNode.innerText then childNode.innerText else if childNode.innerHTML then childNode.innerHTML else childNode.textContent
        text = slugify(textToSlugify)
        aTag = document.createElement('a')
        aTag.setAttribute 'name', text
        pageContent.insertBefore aTag, childNode
        linkToTag = document.createElement('a')
        linkToTag.innerHTML = textToSlugify
        linkToTag.className = 'mdl-navigation__link'
        linkToTag.href = '#' + text
        navigationLinks.appendChild linkToTag
        i += 1
    i++
  util.addEvent window, 'scroll', (event) ->
    scrollY = document.body.scrollTop
    if scrollY >= 585
      if !/fixed/.test(drawer.className)
        drawer.className += ' fixed'
    else
      drawer.className = className
    return
  [
    '//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'
    'http://www.zergnet.com/zerg.js?id=32930'
    'http://www.zergnet.com/zerg.js?id=32875'
  ].map (script) ->
    loadScript script, adsLoaded
    return
  return
