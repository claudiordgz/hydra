
TwitterElements =
  init: () ->
    twitterCards = document.getElementsByClassName('twitter-tweet')[0]
    if twitterCards
      return { src:'//platform.twitter.com/widgets.js', asynchronous: true, element:null }
    else
      return null

init = () ->
  TwitterElements.init()

module.exports = {
  init: init
}