jade = require('jade')

class AdProperties
  constructor: (@width, @height, @srcUrl) ->

adSizes =
  byWidth: [
    AdProperties(180, 150)
    AdProperties(300, 250)
    AdProperties(468, 60)
    AdProperties(600, 520)
    AdProperties(728, 90)
  ]
  byHeight: [
    AdProperties(120, 150)
    AdProperties(120, 240)
    AdProperties(160, 600)
  ]

injectAmazonAd = () ->
  amzBottomAd = document.getElementById('amazon-bottom-ad')
  postContent = document.getElementsByClassName('post-content')
  console.log(postContent)


module.exports = {
  injectAmazonAd : injectAmazonAd
}