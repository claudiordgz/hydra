

refreshIntro = () ->
  wHeight = $(window).height()
  if $('#site-intro').length
    if $('#site-intro').is('.personal')
      if $('.post-list .post').length
        $('#site-intro .author-avatar').html '<img src="' + $('.post-list .post').first().data('author-img') + '" class="img-responsive"/>'
        $('#site-intro .author-name').html $('.post-list .post').first().data('author-name')
        $('#site-intro .author-bio').html $('.post-list .post').first().data('author-bio')
    if $('body').attr('data-site-layout') == 'boxed'
      if $(window).width() >= 1170
        $('#site-intro').css 'height', Math.floor(wHeight * 80 / 100) + 'px'
      else
        $('#site-intro').css 'height', wHeight + 'px'
    else
      $('#site-intro').css 'height', wHeight + 'px'
    if !$('#site-intro').is('.left-style') and !$('#site-intro').is('.right-style')
      introTextMargin = Math.floor($('.intro-text').height() / 2)
      $('.intro-wrap').css 'margin-top', '-' + introTextMargin + 'px'
    $('.intro-wrap').css 'opacity', '1'
    if $('#site-intro .more-detail').length
      $('#site-intro .more-detail').css 'opacity', '1'
  if $('body').is('.post-template') and $('.post-header').length
    percent = 70
    if wHeight <= 600
      percent = 100
    $('.post-header').css 'height', Math.floor(wHeight * percent / 100) + 'px'
    $('.post-header .header-wrap').css 'opacity', '1'
  return

module.exports = {
  refreshTheme: refreshIntro
}