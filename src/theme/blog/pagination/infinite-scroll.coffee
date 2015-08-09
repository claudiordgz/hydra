
format = require "../formatting/format-post-ajax"

getMaxPagination = () ->
  if $('.total-page').length
    return parseInt($('.total-page').html())
  return


infiniteScrollHandler = (SF_THEME_OPTIONS) ->
  if $('.post-list').length and $('body').data('infinite-scroll') == true
    $container = $('.post-list')
    $container.infinitescroll {
      navSelector: '.pagination'
      nextSelector: '.pagination a.older-posts'
      itemSelector: '.post'
      maxPage: getMaxPagination()
      loading:
        finishedMsg: 'No more post to load.'
        img: SF_THEME_OPTIONS.global.rootUrl + '/assets/img/loading.gif'
    }, (newElements) ->
      $newElements = format.formatBlogAjax($(newElements))
      $container.append $newElements
      return
  return

module.exports = { infiniteScrollHandler: infiniteScrollHandler}