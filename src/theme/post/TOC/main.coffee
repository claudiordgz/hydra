touch = require "./touch-events"
contents = require "./contents"

createTOC =
  init: () ->
    contents.contentsTOC.init()
    touch.touchTOC.init()


init = () ->
  createTOC.init()

module.exports = {
  init: init
}