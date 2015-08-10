
minutesLeftToReadThanksForSharingWidget = (app) ->
  $shareBox = $('.share-box')
  if !$('#time-to-read-nofify').length
    $('<div id="time-to-read-nofify"></div>').appendTo 'body'
    if $(window).width() > 1023
      $shareBox.appendTo 'body'
  $timeToReadNofify = $('#time-to-read-nofify')
  $postContent = $('.post-content')
  if !$postContent.data('time-to-read')
    time = Math.round($postContent.text().split(' ').length / 200)
    $postContent.data 'time-to-read', time
  winHeight = $(window).height()
  scrollbarHeight = winHeight / $(document).height() * winHeight
  progress = $(window).scrollTop() / ($(document).height() - winHeight)
  distance = progress * (winHeight - scrollbarHeight) + scrollbarHeight / 2 - ($timeToReadNofify.height() / 2)
  correctScrollToTopBottom = $(window).scrollTop() + screen.height
  otherPos = (document.getElementsByClassName('comment-box')[0]).offsetTop - 500
  if correctScrollToTopBottom < otherPos
    if $(window).width() > 1023
      $shareBox.fadeOut 100
  else
    $timeToReadNofify.fadeOut 100
    if $(window).width() > 1023
      $shareBox.css('top', distance - 150).fadeIn 100
    else
      $shareBox.insertBefore('.comment-box')
  if app.scrollTimer != null
    clearTimeout app.scrollTimer
  app.scrollTimer = setTimeout((->
    $timeToReadNofify.fadeOut()
    return
  ), 1000)
  return

module.exports = {minutesLeftToReadThanksForSharingWidget : minutesLeftToReadThanksForSharingWidget }