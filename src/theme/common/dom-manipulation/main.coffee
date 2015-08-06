

loadScript = (url, async, callback) ->
# Adding the script tag to the head as suggested before
  head = document.getElementsByTagName('head')[0]
  script = document.createElement('script')
  script.type = 'text/javascript'
  script.src = url
  # Then bind the event to the callback function.
  # There are several events for cross browser compatibility.
  script.onreadystatechange = callback
  script.onload = callback
  script.async = async
  # Fire the loading
  head.appendChild script
  return

module.exports = {
  loadScript: loadScript
}