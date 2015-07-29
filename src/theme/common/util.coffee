
moment = require "moment/moment"

isMobile = () ->
  if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    true
  else
    false

formatDate = (date) ->
  moment(date).fromNow()

module.exports = {
  isMobile: isMobile,
  formatDate: formatDate
}