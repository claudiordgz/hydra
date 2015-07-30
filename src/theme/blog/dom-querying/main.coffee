

getMaxPagination = () ->
    if $('.total-page').length
        return parseInt($('.total-page').html())
    return