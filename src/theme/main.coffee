###  TABLE OF CONTENT
    1. Common function
    2. Initialing
###

###================================================================###

###  1. Common function
/*================================================================
###
pagination = require "./pagination/next-post"
formatting = require "./formatting/format-post"
formattingAjax = require "./formatting/format-post-ajax"
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
  audioSeekingHandler: ->
    jQuery(document).on 'click', '.sf-audio-player', (event) ->
      $this = jQuery(this)
      $postHeader = $this.closest('.post-header')
      $playback = jQuery('.header-wrap .line .audio-playback', $postHeader)
      if $playback.is('.playing')
        sfApp.audioScrub $this, event.pageX
      else
        console.log 'audio not playing'
      false
    return
  audioScrub: ($element, xPos) ->
    stream = window.scStreams[$element.data('track-index')]
    needSeek = Math.floor(Math.min(stream.bytesLoaded / stream.bytesTotal, xPos / $element.width()) * stream.durationEstimate)
    console.log 'seek to:' + needSeek
    stream.setPosition needSeek
    return
  audioPlayback: ->
    jQuery(document).on 'click', '.audio-playback', (event) ->
      $this = jQuery(this)
      $postHeader = $this.closest('.post-header')
      if !$this.is('.playing')
        if typeof window.scStreams != 'undefined'
          jQuery.each window.scStreams, (index, stream) ->
            if index != $this.data('track-index')
              window.scStreams[index].pause()
            return
        jQuery('.audio-playback.playing').removeClass 'playing'
        $this.addClass 'playing'
      else
        $this.removeClass 'playing'
      window.scStreams[$this.data('track-index')].togglePause()
      false
    return
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
    if $('.recent-post').length
      $('.recent-post').each ->
        $this = $(this)
        showPubDate = false
        showDesc = false
        descCharacterLimit = -1
        size = -1
        type = 'static'
        slideMode = 'horizontal'
        slideSpeed = 500
        slidePager = false
        isTicker = false
        monthName = new Array
        monthName[0] = 'Jan'
        monthName[1] = 'Feb'
        monthName[2] = 'Mar'
        monthName[3] = 'Apr'
        monthName[4] = 'May'
        monthName[5] = 'June'
        monthName[6] = 'July'
        monthName[7] = 'Aug'
        monthName[8] = 'Sept'
        monthName[9] = 'Oct'
        monthName[10] = 'Nov'
        monthName[11] = 'Dec'
        if $this.data('pubdate')
          showPubDate = $this.data('pubdate')
        if $this.data('desc')
          showDesc = $this.data('desc')
          if $this.data('character-limit')
            descCharacterLimit = $this.data('character-limit')
        if $this.data('size')
          size = $this.data('size')
        if $this.data('type')
          type = $this.data('type')
        if type == 'scroll'
          if $this.data('mode')
            slideMode = $this.data('mode')
          if $this.data('speed')
            slideSpeed = $this.data('speed')
          if $this.data('pager')
            slidePager = $this.data('pager')
          if $this.data('ticker')
            isTicker = $this.data('ticker')
        $.ajax
          type: 'GET'
          url: sfThemeOptions.global.rootUrl + '/rss/'
          dataType: 'xml'
          success: (xml) ->
            if $(xml).length
              htmlStr = ''
              date = undefined
              count = 0
              $('item', xml).each ->
                if size > 0 and count < size
                  htmlStr += '<li class="clearfix">'
                  if showPubDate
                    date = new Date($(this).find('pubDate').eq(0).text())
                    htmlStr += '<span class="itemDate">                                                        <span class="date">' + date.getDate() + '</span>                                                        <span class="month">' + monthName[date.getMonth()] + '</span>                                                    </span>'
                  htmlStr += '<span class="itemContent">'
                  htmlStr += '<span class="title">                                                        <a href="' + $(this).find('link').eq(0).text() + '">                                                        ' + $(this).find('title').eq(0).text() + '                                                        </a>                                                </span>'
                  if showDesc
                    desc = $(this).find('description').eq(0).text()
                    # trip html tag
                    desc = $(desc).text()
                    if descCharacterLimit > 0 and desc.length > descCharacterLimit
                      htmlStr += '<span class="desc">' + desc.substr(0, descCharacterLimit) + ' ...                                                            <a href="' + $(this).find('link').eq(0).text() + '">View »</a>                                                        </span>'
                    else
                      htmlStr += '<span class="desc">' + desc + '</span>'
                  htmlStr += '</span>'
                  htmlStr += '</li>'
                  count++
                else
                  return false
                return
              if type == 'static'
                htmlStr = '<ul class="feedList static">' + htmlStr + '</ul>'
              else
                htmlStr = '<ul class="feedList bxslider">' + htmlStr + '</ul>'
              $this.append htmlStr
              if type != 'static'
# Updating on v1.2
              else
            return
        return
    return
  infiniteScrollHandler: ->
    if $('.post-list').length and $('body').data('infinite-scroll') == true
      $container = $('.post-list')
      $container.infinitescroll {
        navSelector: '.pagination'
        nextSelector: '.pagination a.older-posts'
        itemSelector: '.post'
        maxPage: sfApp.getMaxPagination()
        loading:
          finishedMsg: 'No more post to load.'
          img: sfThemeOptions.global.rootUrl + '/assets/img/loading.gif'
      }, (newElements) ->
        $newElements = sfApp.formatBlogAjax($(newElements))
        $container.append $newElements
        return
    return
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
    $shareBox = $('.share-box')
    if !$('#time-to-read-nofify').length
      $('<div id="time-to-read-nofify"></div>').appendTo 'body'
      if $(window).width() > 979
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
    allMightyHeight = parseFloat(document.body.clientHeight)
    allMightyOffset = allMightyHeight - (allMightyHeight * 0.2)
    otherPos = $('.next-post').offset()
    otherPos = if otherPos.top then otherPos.top else 0
    if correctScrollToTopBottom < allMightyOffset or correctScrollToTopBottom < otherPos
      if $(window).width() > 979
        $shareBox.fadeOut 100
    else
      $timeToReadNofify.fadeOut 100
      if $(window).width() > 979
        $shareBox.css('top', distance - 125).fadeIn 100
    if sfApp.scrollTimer != null
      clearTimeout sfApp.scrollTimer
    sfApp.scrollTimer = setTimeout((->
      $timeToReadNofify.fadeOut()
      return
    ), 1000)
    return
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
    if jQuery('.gmap').length
      your_latitude = jQuery('.gmap').data('latitude')
      your_longitude = jQuery('.gmap').data('longitude')
      mainColor = sfApp.hexColor(jQuery('.gmap-container').css('backgroundColor'))
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
    if jQuery('.gmap').length
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
  init: ->
    SC.initialize client_id: '425fc6ee65a14efbb9b83b1c49a87ccb'
    if typeof window.scStreams == 'undefined'
      window.scStreams = []
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

$(document).ready ->
  'use strict'
  sfApp.init()
  return
$(window).resize ->
  'use strict'
  if @resizeTO
    clearTimeout @resizeTO
  @resizeTO = setTimeout((->
    $(this).trigger 'resizeEnd'
    return
  ), 500)
  return
$(window).bind 'resizeEnd', ->
  'use strict'
  sfApp.refreshIntro()
  return
