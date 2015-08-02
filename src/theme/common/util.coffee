
moment = require "moment/moment"
event = require "./events/main"
dom = require "./dom-manipulation/main"

isMobile = () ->
  if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    true
  else
    false

formatDate = (date) ->
  moment(date).fromNow()

slugify = (text) ->
  text.toString().toLowerCase().replace(/\s+/g, '-').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '-').replace(/^-+/, '').replace /-+$/, ''
# Trim - from end of text


module.exports = {
  isMobile: isMobile,
  formatDate: formatDate
  addEvent: event.addEvent,
  removeEvent: event.removeEvent,
  debounce: event.debounce,
  loadScript: dom.loadScript,
  slugify: slugify
}