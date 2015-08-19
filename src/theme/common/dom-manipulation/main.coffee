

loadScript = (url, async, element, callback) ->
# Adding the script tag to the head as suggested before
  script = document.createElement('script')
  script.type = 'text/javascript'
  script.src = url
  # Then bind the event to the callback function.
  # There are several events for cross browser compatibility.
  script.onreadystatechange = callback
  script.onload = callback
  script.async = async
  script.charset = 'utf-8'
  if element?
    element = document.getElementById(element)
    element.innerHTML += script.outerHTML
  else
    head = document.getElementsByTagName('head')[0]
    # Fire the loading
    head.appendChild script
  return

module.exports = {
  loadScript: loadScript
}