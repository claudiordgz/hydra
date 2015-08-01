

getRecentPosts = (sfThemeOptions) ->
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

module.exports = { getRecentPosts: getRecentPosts }