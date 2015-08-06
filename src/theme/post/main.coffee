
theme = require "../blog/theme"
toc = require "./TOC/main"
scriptLoading = require "../common/dom-manipulation/main"
domready = require "domready"
socialSharing = require "./social_sharing/main"
ads = require "./ads/main"

adsLoaded = ->

setupHandler = (event) ->
  theme.init()
  toc.init()
  adScripts = ads.injectAmazonAd()
  Array::push.apply adScripts, [
    { src:'//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js', async: true }
  ]
  adScripts.map (script) ->
    scriptLoading.loadScript script.src, script.async adsLoaded
    return
  window.removeEventListener('mdl-componentupgraded', setupHandler, false );
  return

domready ->
  window.addEventListener("mdl-componentupgraded", setupHandler, false);