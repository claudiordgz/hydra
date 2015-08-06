
class AdProperties
  constructor: (@width, @height) ->
    @srcUrl = 'http://ir-na.amazon-adsystem.com/s/ads.js'
    @pixelArea = @width * @height

class AdList
  constructor: (contentWidth, screenHeight) ->
    adSizes =
      byWidth: [
        new AdProperties(180, 150)
        new AdProperties(300, 250)
        new AdProperties(468, 60)
        new AdProperties(600, 520)
        new AdProperties(728, 90)
      ]
      byHeight: [
        new AdProperties(120, 150)
        new AdProperties(120, 240)
        new AdProperties(160, 600)
      ]
    @orderAdSizes(values) for key, values of adSizes
    adDimensions = @getAdSizeFromBreakpoints(contentWidth, screenHeight)
    if adDimensions.width > adDimensions.height
      @mainBottomAd = @getAd(adSizes['byWidth'], adDimensions.width, adDimensions.height)
    else if adDimensions.height > adDimensions.width
      @mainBottomAd = @getAd(adSizes['byHeight'], adDimensions.width, adDimensions.height)

  orderAdSizes: (adList) ->
    adList.sort (a, b) ->
      b.pixelArea - a.pixelArea

  getAdSizeFromBreakpoints: (contentWidth, screenHeight) ->
    width = 0
    height = 0
    if contentWidth < 120
      width = 120
      height = 240
    else if contentWidth >= 120 and contentWidth < 300
      width = 160
      height = 600
    else if contentWidth >= 300 and contentWidth < 500
      width = 300
      height = 250
    else if contentWidth >= 500 and contentWidth < 700
      width = 468
      height = 60
    else if contentWidth >= 700
      width = 600
      height = 520
    return {
      width: width,
      height: height,
    }

  getAd: (adList, width, height) ->
    for ad in adList
      if ad.width == width && ad.height == height
        return ad

class Templates
  constructor: ->
    @amazonOmakase = '<script type="text/javascript"><!--amazon_ad_tag = "l0b84-20"; amazon_ad_width = "{{width}}"; amazon_ad_height = "{{height}}"; amazon_ad_link_target = "new"; amazon_ad_border = "hide"; amazon_color_border = "FFFFFF"; amazon_color_link = "1D7AD7"; amazon_color_price = "D10000"; amazon_color_logo = "DD0BF1";//--></script>'

injectAmazonAd = () ->
  postContent = document.getElementsByClassName('post-content')
  postEl
  i = 0
  while i != postContent.length
    if 'post-content' == postContent[i].className
      postEl = postContent[i]
      break
    ++i
  amazonAds = new AdList(postEl.offsetWidth, screen.height)
  amzBottomAd = document.getElementById('amazon-bottom-ad')
  tmpl = new Templates()
  bottomAd = tmpl.amazonOmakase
  bottomAd = bottomAd.replace /\{\{width\}\}/, amazonAds.mainBottomAd.width
  bottomAd = bottomAd.replace /\{\{height\}\}/, amazonAds.mainBottomAd.height
  amzBottomAd.innerHTML = bottomAd
  return [
    { src:amazonAds.mainBottomAd.srcUrl, asynchronous:false, element:'amazon-bottom-ad' }
  ]

module.exports = {
  injectAmazonAd : injectAmazonAd
}