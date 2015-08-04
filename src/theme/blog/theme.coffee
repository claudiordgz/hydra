util = require "../common/util"
pagination = require "./pagination/main"
widgets = require "./widgets/main"
formatting = require "./formatting/format-post"
formattingAjax = require "./formatting/format-post-ajax"
audio = require "./media/audio"

paceOptions = elements: true
trackIndex = 0
sfApp =
  scrollTimer: null
  nextPost: ->
    pagination.nextPost()
  formatBlogAjax: ($newElements) ->
    formattingAjax.formatBlogAjax($newElements)
  formatBlog: ->
    formatting.formatBlog()
  audioPlayback: ->
    audio.audioPlayback()
  videoPlayback: ->
    $(document).on 'click', '.video-playback:not(.vimeo)', (event) ->
      $this = $(this)
      $postHeader = $this.closest('.post-header')
      $video = $postHeader.find('.video')
      if !$this.is('.playing')
        $('.video-playback.playing').removeClass 'playing'
        $this.addClass 'playing'
        $('.post-header.video-post.playing .mb_YTVPlayer').each ->
          $(this).pauseYTP()
          return
        $video.playYTP()
      else
        $this.removeClass 'playing'
        $video.pauseYTP()
      false
    return
  getRecentPosts: ->
    pagination.getRecentPosts(sfThemeOptions)
  infiniteScrollHandler: ->
    pagination.infiniteScrollHandler(sfThemeOptions)
  getFlickr: ->
    if $('.flickr-feed').length
      count = 1
      $('.flickr-feed').each ->
        if flickr_id == '' or flickr_id == 'YOUR_FLICKR_ID_HERE'
          $(this).html '<li><strong>Please change Flickr user id before use this widget</strong></li>'
        else
          feedTemplate = '<li><a href="{{image_b}}" target="_blank"><img src="{{image_m}}" alt="{{title}}" /></a></li>'
          size = 15
          if $(this).data('size')
            size = $(this).data('size')
          isPopupPreview = false
          if $(this).data('popup-preview')
            isPopupPreview = $(this).data('popup-preview')
          if isPopupPreview
            feedTemplate = '<li><a href="{{image_b}}"><img src="{{image_m}}" alt="{{title}}" /></a></li>'
            count++
          $(this).jflickrfeed {
            limit: size
            qstrings: id: flickr_id
            itemTemplate: feedTemplate
          }, (data) ->
            if isPopupPreview
              $(this).magnificPopup
                delegate: 'a'
                type: 'image'
                closeOnContentClick: false
                closeBtnInside: false
                mainClass: 'mfp-with-zoom mfp-img-mobile'
                gallery:
                  enabled: true
                  navigateByImgClick: true
                  preload: [
                    0
                    1
                  ]
                image:
                  verticalFit: true
                  tError: '<a href="%url%">The image #%curr%</a> could not be loaded.'
                zoom:
                  enabled: true
                  duration: 300
                  opener: (element) ->
                    element.find 'img'
            return
        return
    return
  getInstagram: ->
    if $('.instagram-feed').length
      if instagram_accessToken != '' or instagram_accessToken != 'your-instagram-access-token'
        $.fn.spectragram.accessData =
          accessToken: instagram_accessToken
          clientID: instagram_clientID
      $('.instagram-feed').each ->
        if instagram_accessToken == '' or instagram_accessToken == 'your-instagram-access-token'
          $(this).html '<li><strong>Please change instagram api access info before use this widget</strong></li>'
        else
          display = 15
          wrapEachWithStr = '<li></li>'
          if $(this).data('display')
            display = $(this).data('display')
          $(this).spectragram 'getUserFeed',
            query: 'adrianengine'
            max: display
        return
    return
  getDribbble: ->
    if $('.dribbble-feed').length
      count = 1
      $('.dribbble-feed').each ->
        $this = $(this)
        display = 15
        if $this.data('display')
          display = $this.data('display')
        isPopupPreview = false
        if $this.data('popup-preview')
          isPopupPreview = $this.data('popup-preview')
        $.jribbble.getShotsByList 'popular', ((listDetails) ->
            html = []
            $.each listDetails.shots, (i, shot) ->
              if isPopupPreview
                html.push '<li><a href="' + shot.image_url + '">'
              else
                html.push '<li><a href="' + shot.url + '">'
              html.push '<img src="' + shot.image_teaser_url + '" '
              html.push 'alt="' + shot.title + '"></a></li>'
              return
            $this.html html.join('')
            if isPopupPreview
              $this.magnificPopup
                delegate: 'a'
                type: 'image'
                tLoading: 'Loading image #%curr%...'
                mainClass: 'mfp-img-mobile'
                gallery:
                  enabled: true
                  navigateByImgClick: true
                  preload: [
                    0
                    1
                  ]
                image: tError: '<a href="%url%">The image #%curr%</a> could not be loaded.'
            return
          ),
          page: 1
          per_page: display
        return
    return
  fitVids: ->
    $('.post-content').find('iframe[src^="//www.youtube.com"]').wrap '<div class="video-wrap"></div>'
    $('.post-content').find('iframe[src^="//player.vimeo.com"]').wrap '<div class="video-wrap"></div>'
    if $('.post-content').find('>:first-child').is('.video-wrap')
      $('.post-content').find('>:first-child').removeClass 'video-wrap'
    $('.post-content .video-wrap').fitVids()
    return
  timeToRead: ->
    widgets.readShareWidget(sfApp)
  mailchimpHandler: ->
    if $('#mc-form').length
      $('#mc-form input').not('[type=submit]').jqBootstrapValidation submitSuccess: ($form, event) ->
        event.preventDefault()
        url = $form.attr('action')
        if url == '' or url == 'YOUR_WEB_FORM_URL_HERE'
          alert 'Please config your mailchimp form url for this widget'
          false
        else
          url = url.replace('/post?', '/post-json?').concat('&c=?')
          data = {}
          dataArray = $form.serializeArray()
          $.each dataArray, (index, item) ->
            data[item.name] = item.value
            return
          $.ajax
            url: url
            data: data
            success: (resp) ->
              if resp.result == 'success'
                alert 'Got it, you\'ve been added to our newsletter. Thanks for subscribe!'
              else
                alert resp.result
              return
            dataType: 'jsonp'
            error: (resp, text) ->
              console.log 'mailchimp ajax submit error: ' + text
              return
          false
    return
  scrollEvent: ->
    $(window).scroll ->
      'use strict'
      if $('.header').attr('data-sticky') == 'true'
        curPos = $(window).scrollTop()
        if curPos >= $('.header').height()
          $('.header').addClass 'fixed-top'
          if $('.logo-container .logo img').length and !$('.logo-container .logo img').is('.apply-sticked') and $('.logo-container .logo img').attr('data-sticked-src') != ''
            $('.logo-container .logo img').attr 'data-normal-src', $('.logo-container .logo img').attr('src')
            $('.logo-container .logo img').attr 'src', $('.logo-container .logo img').attr('data-sticked-src')
            $('.logo-container .logo img').addClass 'apply-sticked'
        else
          $('.header').removeClass 'fixed-top'
          if $('.logo-container .logo img').length and $('.logo-container .logo img').is('.apply-sticked') and $('.logo-container .logo img').attr('data-normal-src') != ''
            $('.logo-container .logo img').attr 'data-sticked-src', $('.logo-container .logo img').attr('src')
            $('.logo-container .logo img').attr 'src', $('.logo-container .logo img').attr('data-normal-src')
            $('.logo-container .logo img').removeClass 'apply-sticked'
      if $('body').is('.post-template') and !$('body').is('.page') and $('.post-content').length
        sfApp.timeToRead()
      return
    return
  menuEvent: ->
    if $('.mini-nav-button').length
      $('.mini-nav-button').click ->
        $menu = $('.full-screen-nav')
        if !$menu.length
          $menu = $('.mini-nav')
          if !$menu.length
            $menu = $('.standard-nav')
        if !$(this).is('.active')
          $('body').addClass 'open-menu'
          $menu.addClass 'open'
          $(this).addClass 'active'
        else
          $('body').removeClass 'open-menu'
          $menu.removeClass 'open'
          $(this).removeClass 'active'
        return
    if $('.search-button').length
      $('.search-button').click ->
        $('#search-keyword').val ''
        $search = $('.search-container')
        if !$(this).is('.active')
          $('body').addClass 'open-search'
          $search.addClass 'open'
          $(this).addClass 'active'
          $('#search-keyword').focus()
        else
          $('body').removeClass 'open-search'
          $search.removeClass 'open'
          $(this).removeClass 'active'
          $('.search-result').removeClass 'searching'
        return
    return
  gmapInitialize: ->
    if $('.gmap').length
      your_latitude = $('.gmap').data('latitude')
      your_longitude = $('.gmap').data('longitude')
      mainColor = sfApp.hexColor($('.gmap-container').css('backgroundColor'))
      myLatlng = new (google.maps.LatLng)(your_latitude, your_longitude)
      mapOptions =
        zoom: 17
        mapTypeId: google.maps.MapTypeId.ROADMAP
        mapTypeControl: false
        panControl: false
        zoomControl: false
        scaleControl: false
        streetViewControl: false
        scrollwheel: false
        center: myLatlng
        styles: [ { 'stylers': [ {
          'hue': mainColor
          'lightness': 100
        } ] } ]
      map = new (google.maps.Map)(document.getElementById('gmap'), mapOptions)
      markerIcon = new (google.maps.MarkerImage)(sfThemeOptions.global.rootUrl + '/assets/img/map-marker.png', null, null, new (google.maps.Point)(32, 32), new (google.maps.Size)(64, 64))
      marker = new (google.maps.Marker)(
        position: myLatlng
        flat: true
        icon: markerIcon
        map: map
        optimized: false
        title: 'i-am-here'
        visible: true)
    return
  hexColor: (colorval) ->
    parts = colorval.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/)
    delete parts[0]
    i = 1
    while i <= 3
      parts[i] = parseInt(parts[i]).toString(16)
      if parts[i].length == 1
        parts[i] = '0' + parts[i]
      ++i
    '#' + parts.join('')
  setCookie: (key, value) ->
    expires = new Date
    expires.setTime expires.getTime() + 1 * 24 * 60 * 60 * 1000
    document.cookie = key + '=' + value + ';path=/;expires=' + expires.toUTCString()
    return
  getCookie: (key) ->
    keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)')
    if keyValue then keyValue[2] else null
  searchHandler: ->
    $('#search-keyword').keypress (event) ->
      if event.which == 13
        if $('#search-keyword').val() != '' and $('#search-keyword').val().length >= 3
          $('.search-result').html '<li class="loading-text">Searching ...</li>'
          $('.search-result').addClass 'searching'
          sfApp.search $('#search-keyword').val()
        else
          $('.search-result').html '<li class="loading-text">Please enter at least 3 characters!</li>'
          $('.search-result').addClass 'searching'
      return
    return
  search: (keyword) ->
    hasResult = false
    page = 0
    maxPage = 0
    if keyword != ''
      $.ajax
        type: 'GET'
        url: sfThemeOptions.global.rootUrl
        success: (response) ->
          $response = $(response)
          postPerPage = $response.find('section.post').length
          totalPage = parseInt($response.find('.total-page').html())
          maxPage = Math.floor(postPerPage * totalPage / 15) + 1
          timeout = setInterval((->
            page = page + 1
            ajaxUrl = sfThemeOptions.global.rootUrl + '/rss/' + page + '/'
            if page == 1
              ajaxUrl = sfThemeOptions.global.rootUrl + '/rss/'
            if page > maxPage
              clearInterval timeout
              if !hasResult
                $('.search-result .loading-text').html 'Apologies, but no results were found. Please try another keyword!'
            else
              $.ajax
                type: 'GET'
                url: ajaxUrl
                dataType: 'xml'
                success: (xml) ->
                  if $(xml).length
                    $('item', xml).each ->
                      if $(this).find('title').eq(0).text().toLowerCase().indexOf(keyword.toLowerCase()) >= 0 or $(this).find('description').eq(0).text().toLowerCase().indexOf(keyword.toLowerCase()) >= 0
                        hasResult = true
                        if $('.search-result .loading-text').length
                          $('.search-result .loading-text').remove()
                        $('.search-result').append '<li><a href="' + $(this).find('link').eq(0).text() + '">' + $(this).find('title').eq(0).text() + '</a></li>'
                      return
                  return
            return
          ), 1000)
          return
    return
  refreshIntro: ->
    pagination.refreshTheme()
  misc: ->
    $('.more-detail .scrollDown').click ->
      $('html, body').animate { scrollTop: $('#start').offset().top - $('.header').outerHeight() + 20 }, 500
      false
    $('.more-detail .start').click ->
      $('html, body').animate { scrollTop: $('#start').offset().top - $('.header').outerHeight() + 20 }, 500
      false
    $('.action-list .go-to-blog').click ->
      $('html, body').animate { scrollTop: $('#start').offset().top - $('.header').outerHeight() + 20 }, 500
      false
    if $('.totop-btn').length
      $('.totop-btn').click ->
        $('html, body').animate { scrollTop: 0 }, 800
        false
    if $('.go-to-comment').length
      $('.go-to-comment').click (event) ->
        $('html, body').stop().animate { scrollTop: $('.comment-wrap').offset().top }, 500
        return
    if $('body').is('.post-template') or $('body').is('.page-template')
      $imgList = $('.post-content').find('img')
      if $imgList.length
        $imgList.each (index, el) ->
          alt = $(this).attr('alt')
          $(this).addClass 'img-responsive'
          $(this).addClass alt
          if !alt
            return
          if alt.indexOf('no-responsive') >= 0
            $(this).removeClass 'img-responsive'
          if alt.indexOf('fullscreen-img') >= 0
            $(this).wrap '<span class="fullscreen-img-wrap"></span>'
            $fullscreenImgWrap = $(this).closest('.fullscreen-img-wrap')
            $(this).on 'load', ->
              $fullscreenImgWrap.css 'height': $(this).outerHeight()
              return
          else if alt.indexOf('popup-preview') >= 0 or $('body').data('auto-image-popup-preview')
            $(this).wrap '<a class="popup-preview" href="' + $(this).attr('src') + '"></a>'
            $wrap = $(this).parent()
            if alt.indexOf('alignright') >= 0
              $wrap.addClass 'alignright'
            if alt.indexOf('alignleft') >= 0
              $wrap.addClass 'alignleft'
            if alt.indexOf('aligncenter') >= 0
              $wrap.addClass 'aligncenter'
            $('.popup-preview').magnificPopup
              type: 'image'
              closeOnContentClick: true
              closeBtnInside: false
              fixedContentPos: true
              mainClass: 'mfp-no-margins mfp-with-zoom'
              image: verticalFit: true
              gallery: enabled: true
              zoom:
                enabled: true
                duration: 300
          return
    if $('.gmap').length
      sfApp.gmapInitialize()
      google.maps.event.addDomListener window, 'load', sfApp.gmapInitialize
      google.maps.event.addDomListener window, 'resize', sfApp.gmapInitialize
    $menu = $('.full-screen-nav')
    if !$menu.length
      $menu = $('.mini-nav')
      if !$menu.length
        $menu = $('.standard-nav')
    currentUrl = window.location.href
    $currentMenu = $menu.find('a[href="' + currentUrl + '"]')
    if $currentMenu.length
      $('li.active', $menu).removeClass 'active'
      $currentMenu.parent().addClass 'active'
    $('input, textarea').placeholder()
    return
  setup: ->
    sfApp.refreshIntro()
    sfApp.formatBlog()
    sfApp.nextPost()
    sfApp.infiniteScrollHandler()
    sfApp.fitVids()
    sfApp.audioPlayback()
    sfApp.videoPlayback()
    sfApp.scrollEvent()
    sfApp.menuEvent()
    sfApp.searchHandler()
    sfApp.mailchimpHandler()
    sfApp.misc()
    return

###================================================================###

###  2. Initialing
/*================================================================
###

themeRefreshIntro =  () ->
  util.debounce((->
    sfApp.refreshIntro()
  ), 500)

init = () ->
  sfApp.setup()
  util.addEvent window, 'resize', (event) ->
    themeRefreshIntro()


module.exports = {init: init}