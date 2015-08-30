
util = require "../../common/util"

formatBlog = () ->
  if $('.post').length and ($('body').is('.post-template') or $('body').attr('data-post-mode') == 'multimedia' and ($('body').is('.home-template') or $('body').is('.archive-template') or $('body').is('.tag-template')))
    $('.post').imagesLoaded ->
      $('.post:not(.formated)').each ->
        $this = $(this)
        $postHeader = $this.find('.post-header')
        $postContent = $this.find('.post-content')
        $line = $postHeader.find('.line')
        # Video Post only by IFRAME
        if $postContent.has('iframe[src^="//www.youtube.com"]').length
          $videoEl = $postContent.find('iframe[src^="//www.youtube.com"]')
          regExp = /youtube(-nocookie)?\.com\/(embed|v)\/([\w_-]+)/
          regResult = $videoEl.attr('src').match(regExp)
          if regResult[3] != undefined and regResult[3] != ''
            $postHeader.addClass 'has-background video-post'
            $line.addClass 'has-icon'
            if util.isMobile()
              $postHeader.addClass 'mobile'
              $postHeader.css 'background-image', 'url("' + 'http://i3.ytimg.com/vi/' + regResult[3] + '/0.jpg' + '")'
              $line.html '<a class="video-playback youtube" href="http://www.youtube.com/watch?v=' + videoUrl + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
              $videoPlayback = $line.find('.video-playback')
              $('.video-playback', $line).tooltip()
              $videoPlayback.magnificPopup
                type: 'iframe'
                mainClass: 'mfp-fade'
                removalDelay: 160
                preloader: false
                fixedContentPos: false
            else
              videoUrl = 'http://www.youtube.com/watch?v=' + regResult[3]
              videoData = '{videoURL:\'' + videoUrl + '\', containment:\'self\', showControls:true, startAt:0, mute:false, autoPlay:false, loop:false, opacity:1, quality:\'highres\'}'
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
        if $postContent.has('iframe[src^="//player.vimeo.com"]').length
          $vimeoVideoEl = $postContent.find('iframe[src^="//player.vimeo.com"]')
          vimeoVideoUrl = $vimeoVideoEl.attr('src')
          vimeoId = ''
          regExp = /video\/(\d+)/
          regResult = vimeoVideoUrl.match(regExp)
          if regResult.length and regResult[1] != ''
            vimeoId = regResult[1]
          if !$postHeader.is('has-background') and vimeoId != ''
            vimeoUrl = 'http://vimeo.com/api/v2/video/' + vimeoId + '.json'
            $.ajax
              type: 'GET'
              url: vimeoUrl
              dataType: 'json'
              success: (result) ->
                `var $videoPlayback`
                if result.length
                  $postHeader.addClass 'video-post vimeo'
                  $postHeader.css 'background-image', 'url("' + result[0].thumbnail_large + '")'
                return
          $line.html '<a class="video-playback vimeo" href="https://vimeo.com/' + vimeoId + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
          $line.addClass 'has-icon'
          $videoPlayback = $line.find('.video-playback')
          $videoPlayback.tooltip()
          $videoPlayback.magnificPopup
            type: 'iframe'
            mainClass: 'mfp-fade'
            removalDelay: 160
            preloader: false
            fixedContentPos: false
            callbacks:
              open: ->
  # Will fire when this exact popup is opened
  # this - is Magnific Popup object
                return
              close: ->
                console.log $videoPlayback.html()
                return
        if $postContent.has('iframe[src^="https://w.soundcloud.com"]').length
          $audioEl = $postContent.find('iframe[src^="https://w.soundcloud.com"]')
          regExp = /soundcloud.com\/tracks\/(\d+)/
          regResult = $audioEl.attr('src').match(regExp)
          if regResult.length and regResult[1] != ''
            $postHeader.append '<div class="sf-audio-player"></div>'
            $audioPlayer = $postHeader.find('.sf-audio-player')
            $audioPlayer.data 'track-id', regResult[1]
            $section = $postHeader.closest('section')
            $line.html '<a class="audio-playback" href="javascript:;" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
            $line.addClass 'has-icon'
            $playback = $line.find('.audio-playback')
            $playback.tooltip()
            waveformColor = $section.css('background-color')
            if !$postHeader.is('.has-background')
              if $section.is('.even') or $('body').is('.post-template')
                waveformColor = 'rgba(255,255,255,0.4)'
              else
                waveformColor = 'rgba(0,0,0,0.4)'
            SC.get '/tracks/' + regResult[1], (track) ->
              waveform = new Waveform(
                container: $audioPlayer[0]
                innerColor: waveformColor)
              waveform.dataFromSoundCloudTrack track
              streamOptions = waveform.optionsForSyncedStream()
              onfinishOptions = onfinish: ->
                $playback.removeClass 'playing'
                console.log 'track finished'
                return
              $.extend streamOptions, onfinishOptions
              SC.stream track.uri, streamOptions, (stream) ->
                window.scStreams.push stream
                return
              return
            $audioPlayer.data 'track-index', trackIndex
            $playback.data 'track-index', trackIndex
            $audioPlayer.addClass 'inited'
            trackIndex++
        else if $postHeader.is('.has-background')
          bg_url = $postHeader.css('background-image')
          bg_url = bg_url.replace(/.*\s?url\([\'\"]?/, '').replace(/[\'\"]?\).*/, '')
          $line.html '<a class="image-popup" href="' + bg_url + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
          $line.addClass 'has-icon'
          $line.find('.image-popup').tooltip()
          $line.find('.image-popup').magnificPopup
            type: 'image'
            tLoading: ''
        else if $postContent.has('img[alt*="image-post"]').length
          $backgroundEl = $postContent.find('img[alt*="image-post"]')
          $postHeader.addClass 'has-background ' + $backgroundEl.attr('alt')
          $postHeader.css 'background-image', 'url("' + $backgroundEl.attr('src') + '")'
          $line.html '<a class="image-popup" href="' + $backgroundEl.attr('src') + '" data-toggle="tooltip" data-placement="right" title="Try me!"></a>'
          $line.addClass 'has-icon'
          $line.find('.image-popup').tooltip()
          $line.find('.image-popup').magnificPopup
            type: 'image'
            tLoading: ''
        $this.addClass 'formated'
        return
      return
  return

module.exports = { formatBlog: formatBlog }