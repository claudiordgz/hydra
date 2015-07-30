
format = require "../formatting/format-post-ajax"

infiniteScrollHandler = (sfThemeOptions) ->
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
      $newElements = format.formatBlogAjax($(newElements))
      $container.append $newElements
      return
  return

module.exports = { infiniteScrollHandler: infiniteScrollHandler}