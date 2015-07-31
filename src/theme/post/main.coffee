
app = require "../blog/theme"
toc = require "./TOC/main"

adsLoaded = ->

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


$(document).ready ->
  app.init()
  toc.init()
  [
    '//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'
    #'http://ws-na.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&MarketPlace=US&ID=V20070822%2FUS%2Fl0b84-20%2F8009%2Fc59a34de-018f-4ef1-90c8-662ff2f20823&Operation=GetScriptTemplate', # 728X90
    #'http://ws-na.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&MarketPlace=US&ID=V20070822%2FUS%2Fl0b84-20%2F8009%2F71a3dc79-1756-491a-90d8-8a39dcf9598f&Operation=GetScriptTemplate', # 468X60
    #'http://ir-na.amazon-adsystem.com/s/ads.js'
  ].map (script) ->
    loadScript script, adsLoaded
    return
  return
