
util = require "../../common/util"

formatBlogAjax = ($newElements) ->
  if $newElements.length and ($('body').is('.post-template') or $('body').attr('data-post-mode') == 'multimedia' and ($('body').is('.home-template') or $('body').is('.archive-template') or $('body').is('.tag-template')))
    $.each $newElements, (i, val) ->
      $this = $(val)
      $postHeader = $this.find('.post-header')
      $postContent = $this.find('.post-content')
      # Image Post
      if $postContent.has('img[alt*="image-post"]').length
        $backgroundEl = $postContent.find('img[alt*="image-post"]')
        $postHeader.addClass $backgroundEl.attr('alt')
        $postHeader.css 'background-image', 'url("' + $backgroundEl.attr('src') + '")'
      else if $postContent.has('a[href*="youtube.com"]').length
        $videoEl = $postContent.find('a[href*="youtube.com"]')
        if $videoEl.length
          videoUrl = $videoEl.attr('href')
          if videoUrl != ''
            $postHeader.addClass 'has-background video-post'
            $line = $postHeader.find('.line')
            if util.isMobile()
              $postHeader.addClass 'mobile'
              youtubeId = videoUrl.match(/[\\?&]v=([^&#]*)/)[1]
              if youtubeId != ''
                $postHeader.css 'background-image', 'url("' + 'http://i3.ytimg.com/vi/' + youtubeId + '/0.jpg' + '")'
                $line.html '<a class="video-playback youtube" href="' + videoUrl + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
                $('.video-playback', $line).tooltip()
                $videoPlayback = $line.find('.video-playback')
                $videoPlayback.magnificPopup
                  type: 'iframe'
                  mainClass: 'mfp-fade'
                  removalDelay: 160
                  preloader: false
                  fixedContentPos: false
            else
              videoData = '{videoURL:\'' + videoUrl + '\',containment:\'self\',showControls:true,startAt:0,mute:false,autoPlay:false,loop:false,opacity:1,quality:\'highres\'}'
              $postHeader.append '<div class="video player"></div>'
              $video = $postHeader.find('.video')
              $video.data 'property', videoData
              $video.mb_YTPlayer()
              $video.on 'YTPStart', ->
                $postHeader.addClass 'playing'
                return
              $video.on 'YTPPause', ->
                $postHeader.removeClass 'playing'
                return
              $video.on 'YTPEnd', ->
                `var $video`
                `var videoData`
                `var videoUrl`
                `var $videoPlayback`
                `var $line`
                `var $videoEl`
                $postHeader.removeClass 'playing'
                return
              $line.html '<a class="video-playback youtube" href="javascript:;" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
              $('.video-playback', $line).tooltip()
      else if $postContent.has('iframe[src^="//www.youtube.com"]').length
        $videoEl = $postContent.find('iframe[src^="//www.youtube.com"]')
        regExp = /youtube(-nocookie)?\.com\/(embed|v)\/([\w_-]+)/
        regResult = $videoEl.attr('src').match(regExp)
        if regResult[3] != undefined and regResult[3] != ''
          $postHeader.addClass 'has-background video-post'
          $line = $postHeader.find('.line')
          if util.isMobile()
            $postHeader.addClass 'mobile'
            $postHeader.css 'background-image', 'url("' + 'http://i3.ytimg.com/vi/' + regResult[3] + '/0.jpg' + '")'
            $line.html '<a class="video-playback youtube" href="http://www.youtube.com/watch?v=' + videoUrl + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
            $('.video-playback', $line).tooltip()
            $videoPlayback = $line.find('.video-playback')
            $videoPlayback.magnificPopup
              type: 'iframe'
              mainClass: 'mfp-fade'
              removalDelay: 160
              preloader: false
              fixedContentPos: false
          else
            videoUrl = 'http://www.youtube.com/watch?v=' + regResult[3]
            videoData = '{videoURL:\'' + videoUrl + '\', containment:\'self\',showControls:true, startAt:0,mute:false,autoPlay:false,loop:false, opacity:1,quality:\'highres\'}'
            $postHeader.append '<div class="video player"></div>'
            $video = $postHeader.find('.video')
            $video.data 'property', videoData
            $video.mb_YTPlayer()
            $video.on 'YTPStart', ->
              $postHeader.addClass 'playing'
              return
            $video.on 'YTPPause', ->
              $postHeader.removeClass 'playing'
              return
            $video.on 'YTPEnd', ->
              `var regResult`
              `var regExp`
              $postHeader.removeClass 'playing'
              return
            $line.html '<a class="video-playback youtube" href="javascript:;" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
            $('.video-playback', $line).tooltip()
      else if $postContent.has('a[href*="vimeo.com"]').length
        $vimeoVideoEl = $postContent.find('a[href*="vimeo.com"]')
        vimeoVideoUrl = $vimeoVideoEl.attr('href')
        # get vimeo thumnail
        regExp = /vimeo.com\/(\d+)/
        vimeoId = ''
        regResult = vimeoVideoUrl.match(regExp)
        if regResult.length
          vimeoId = regResult[1]
        if vimeoId != ''
          vimeoUrl = 'http://vimeo.com/api/v2/video/' + vimeoId + '.json'
          $.ajax
            type: 'GET'
            url: vimeoUrl
            dataType: 'json'
            success: (result) ->
              `var vimeoUrl`
              `var regResult`
              `var vimeoId`
              `var regExp`
              `var vimeoVideoUrl`
              `var $vimeoVideoEl`
              `var $videoPlayback`
              `var $line`
              if result.length
                $postHeader.addClass 'has-background video-post vimeo'
                $postHeader.css 'background-image', 'url("' + result[0].thumbnail_large + '")'
                $line = $postHeader.find('.line')
                $line.html '<a class="video-playback vimeo" href="' + vimeoVideoUrl + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
                $('.video-playback', $line).tooltip()
                $videoPlayback = $line.find('.video-playback')
                $videoPlayback.magnificPopup
                  type: 'iframe'
                  mainClass: 'mfp-fade'
                  removalDelay: 160
                  preloader: false
                  fixedContentPos: false
              return
      else if $postContent.has('iframe[src^="//player.vimeo.com"]').length
        $vimeoVideoEl = $postContent.find('iframe[src^="//player.vimeo.com"]')
        vimeoVideoUrl = $vimeoVideoEl.attr('src')
        # get vimeo thumnail
        regExp = /video\/(\d+)/
        vimeoId = ''
        regResult = vimeoVideoUrl.match(regExp)
        if regResult != null
          vimeoId = regResult[1]
        if vimeoId != ''
          vimeoUrl = 'http://vimeo.com/api/v2/video/' + vimeoId + '.json'
          $.ajax
            type: 'GET'
            url: vimeoUrl
            dataType: 'json'
            success: (result) ->
              `var $line`
              `var $audio`
              `var regResult`
              `var regExp`
              `var $audioEl`
              `var $line`
              `var $videoPlayback`
              `var $line`
              if result.length
                $postHeader.addClass 'has-background video-post vimeo'
                $postHeader.css 'background-image', 'url("' + result[0].thumbnail_large + '")'
                $line = $postHeader.find('.line')
                $line.html '<a class="video-playback vimeo" href="https://vimeo.com/' + vimeoId + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
                $('.video-playback', $line).tooltip()
                $videoPlayback = $line.find('.video-playback')
                $videoPlayback.magnificPopup
                  type: 'iframe'
                  mainClass: 'mfp-fade'
                  removalDelay: 160
                  preloader: false
                  fixedContentPos: false
              return
      else if $postContent.has('a[href*="soundcloud.com"]').length
        $audioEl = $postContent.find('a[href*="soundcloud.com"]')
        $postHeader.append '<div class="audio sc-player"></div>'
        $audio = $postHeader.find('.audio')
        $audioEl.appendTo $audio
        $postHeader.addClass 'has-background audio-post'
        $audio.scPlayer randomize: true
        $line = $postHeader.find('.line')
        $line.html '<a class="audio-playback" href="javascript:;" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
        $('.audio-playback', $line).tooltip()
      else if $postContent.has('iframe[src^="https://w.soundcloud.com"]').length
        $audioEl = $postContent.find('iframe[src^="https://w.soundcloud.com"]')
        regExp = /soundcloud.com\/tracks\/(\d+)/
        soundcloudUrl = ''
        regResult = $audioEl.attr('src').match(regExp)
        if regResult.length and regResult[1] != ''
          $postHeader.append '<div class="audio sc-player"><a href="http://api.soundcloud.com/tracks/' + regResult[1] + '"></a></div>'
          $audio = $postHeader.find('.audio')
          $postHeader.addClass 'has-background audio-post'
          $audio.scPlayer randomize: true
          $line = $postHeader.find('.line')
          $line.html '<a class="audio-playback" href="javascript:;" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
          $('.audio-playback', $line).tooltip()
      $this.addClass 'formated'
      return
  $newElements

module.exports = { formatBlogAjax: formatBlogAjax }