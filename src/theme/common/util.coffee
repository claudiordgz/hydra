
moment = require "moment/moment"

isMobile = () ->
  if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    true
  else
    false

formatDate = (date) ->
  moment(date).fromNow()

addEvent = (obj, type, fn) ->
  if obj.attachEvent
    obj['e' + type + fn] = fn

    obj[type + fn] = ->
      obj['e' + type + fn] window.event
      return

    obj.attachEvent 'on' + type, obj[type + fn]
  else
    obj.addEventListener type, fn, false
  return

removeEvent = (obj, type, fn) ->
  if obj.detachEvent
    obj.detachEvent 'on' + type, obj[type + fn]
    obj[type + fn] = null
  else
    obj.removeEventListener type, fn, false
  return

module.exports = {
  isMobile: isMobile,
  formatDate: formatDate
  addEvent: addEvent,
  removeEvent: removeEvent
}