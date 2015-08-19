
theme = require "../blog/theme"
toc = require "./TOC/main"
scriptLoading = require "../common/dom-manipulation/main"
domready = require "domready"
socialSharing = require "./social_sharing/main"

adsLoaded = ->

setupHandler = (event) ->
  theme.init()
  toc.init()
  twitter = socialSharing.twitter()
  asyncJS = [
    { src:'//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js', asynchronous: true, element:null }
  ]
  asyncJS.push(twitter) if twitter
  asyncJS.map (script) ->
    scriptLoading.loadScript script.src, script.asynchronous, script.element, adsLoaded
    return
  window.removeEventListener('mdl-componentupgraded', setupHandler, false );
  return

domready ->
  window.addEventListener("mdl-componentupgraded", setupHandler, false);