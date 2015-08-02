
util = require "../../common/util"

nextPost = () ->
  if $('.next-post').length
    page = 0
    isNext = false
    result = new Array
    $nextPostContainer = $('.next-post')
    currentUrl = $nextPostContainer.data('current-url')
    if currentUrl != ''
      timeout = setInterval((->
        page = page + 1
        ajaxUrl = sfThemeOptions.global.rootUrl + '/rss/' + page + '/'
        if page == 1
          ajaxUrl = sfThemeOptions.global.rootUrl + '/rss/'
        $.ajax
          type: 'GET'
          url: ajaxUrl
          dataType: 'xml'
          success: (xml) ->
            if $(xml).length
              $('item', xml).each ->
                `var regResult`
                `var regExp`
                itemUrl = $(this).find('link').eq(0).text()
                if isNext
                  result['link'] = itemUrl
                  result['title'] = $(this).find('title').eq(0).text()
                  result['pubDate'] = util.formatDate(new Date($(this).find('pubDate').eq(0).text()))
                  $desc = $(this).find('description')
                  $desc = $desc.eq(0).text()
                  if /<[a-z][\s\S]*>/i.test($desc)
                    $desc = $($desc)
                    if $desc.first().is('iframe')
                      $iframeEl = $desc.first()
                      frameSrc = $desc.first().attr('src')
                      if frameSrc.indexOf('youtube.com') >= 0
                        regExp = /youtube(-nocookie)?\.com\/(embed|v)\/([\w_-]+)/
                        youtubeId = ''
                        regResult = frameSrc.match(regExp)
                        if regResult[3] != 'undefined' and regResult[3] != ''
                          result['background'] = 'http://i3.ytimg.com/vi/' + regResult[3] + '/0.jpg'
                          result['cssClass'] = 'video-post'
                      else if frameSrc.indexOf('vimeo.com') >= 0
                        regExp = /video\/(\d+)/
                        regResult = frameSrc.match(regExp)
                        if regResult[1] != 'undefined' and regResult[1] != ''
                          vimeoUrl = 'http://vimeo.com/api/v2/video/' + regResult[1] + '.json'
                          console.log vimeoUrl
                          $.ajax
                            type: 'GET'
                            url: vimeoUrl
                            dataType: 'json'
                            success: (vimeoResult) ->
                              `var vimeoUrl`
                              `var regResult`
                              `var regExp`
                              `var youtubeId`
                              if vimeoResult.length
                                $nextPostContainer.css 'background-image', 'url("' + vimeoResult[0].thumbnail_large + '")'
                                $nextPostContainer.addClass 'video-post'
                                htmlStr = '<div class="next-post-wrap">                                                                                <div class="next-label">Next Story</div>                                                                                <h2 class="post-title"><a href="' + result['link'] + '">' + result['title'] + '</a></h2>                                                                                <div class="post-meta">' + result['pubDate'] + '</div>                                                                                <div class="next-arrow"><a href="' + result['link'] + '"><i class="fa fa-angle-double-down"></i></a></div>                                                                            </div>'
                                $nextPostContainer.html htmlStr
                              return
                    else if $desc.has('img[alt*="image-post"]').length
                      $backgroundEl = $desc.find('img[alt*="image-post"]')
                      if $backgroundEl.length
                        result['cssClass'] = $backgroundEl.attr('alt')
                        result['background'] = $backgroundEl.attr('src')
                    else if $desc.has('a[href*="youtube.com"]').length
                      $videoEl = $desc.find('a[href*="youtube.com"]')
                      if $videoEl.length
                        videoUrl = $videoEl.attr('href')
                        if videoUrl != ''
                          youtubeId = videoUrl.match(/[\\?&]v=([^&#]*)/)[1]
                          if youtubeId != ''
                            result['background'] = 'http://i3.ytimg.com/vi/' + youtubeId + '/0.jpg'
                            result['cssClass'] = 'video-post'
                    else if $desc.has('a[href*="vimeo.com"]').length
                      $vimeoVideoEl = $desc.find('a[href*="vimeo.com"]')
                      vimeoVideoUrl = $vimeoVideoEl.attr('href')
                      regExp = /vimeo.com\/(\d+)/
                      vimeoId = ''
                      regResult = vimeoVideoUrl.match(regExp)
                      if regResult[1] != 'undefined' and regResult[1] != ''
                        vimeoUrl = 'http://vimeo.com/api/v2/video/' + regResult[1] + '.json'
                        $.ajax
                          type: 'GET'
                          url: vimeoUrl
                          dataType: 'json'
                          success: (vimeoResult) ->
                            if vimeoResult.length and vimeoResult[0].thumbnail_large != ''
                              $nextPostContainer.css 'background-image', 'url("' + vimeoResult[0].thumbnail_large + '")'
                              $nextPostContainer.addClass 'video-post'
                              htmlStr = '<div class="next-post-wrap">                                                                            <div class="next-label">Next Story</div>                                                                            <h2 class="post-title"><a href="' + result['link'] + '">' + result['title'] + '</a></h2>                                                                            <div class="post-meta">' + result['pubDate'] + '</div>                                                                            <div class="next-arrow"><a href="' + result['link'] + '"><i class="fa fa-angle-double-down"></i></a></div>                                                                        </div>'
                              $nextPostContainer.html htmlStr
                            return
                    if result['link'] != undefined
                      if result['background'] != undefined and result['background'] != ''
                        $nextPostContainer.css 'background-image', 'url("' + result['background'] + '")'
                      if result['cssClass'] != undefined and result['cssClass'] != ''
                        $nextPostContainer.addClass result['cssClass']
                      htmlStr = '<div class="next-post-wrap">                                                            <div class="next-label">Next Story</div>                                                            <h2 class="post-title"><a href="' + result['link'] + '">' + result['title'] + '</a></h2>                                                            <div class="post-meta">' + result['pubDate'] + '</div>                                                            <div class="next-arrow"><a href="' + result['link'] + '"><i class="fa fa-angle-double-down"></i></a></div>                                                        </div>'
                      $nextPostContainer.html htmlStr
                    clearInterval timeout
                    return false
                else if currentUrl == itemUrl
                  isNext = true
                return
            return
        return
      ), 2000)
  return

module.exports = { nextPost: nextPost }