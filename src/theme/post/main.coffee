
theme = require "../blog/theme"
toc = require "./TOC/main"
scriptLoading = require "../common/dom-manipulation/main"
domready = require "domready"
socialSharing = require "./social_sharing/main"

adsLoaded = ->

domready ->
  theme.init()
  toc.init()
  [
    '//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'
    #'http://ws-na.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&MarketPlace=US&ID=V20070822%2FUS%2Fl0b84-20%2F8009%2Fc59a34de-018f-4ef1-90c8-662ff2f20823&Operation=GetScriptTemplate', # 728X90
    #'http://ws-na.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&MarketPlace=US&ID=V20070822%2FUS%2Fl0b84-20%2F8009%2F71a3dc79-1756-491a-90d8-8a39dcf9598f&Operation=GetScriptTemplate', # 468X60
    #'http://ir-na.amazon-adsystem.com/s/ads.js'
  ].map (script) ->
    scriptLoading.loadScript script, adsLoaded
    return
  return
