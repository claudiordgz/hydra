

audioScrub = ($element, xPos) ->
  stream = window.scStreams[$element.data('track-index')]
  needSeek = Math.floor(Math.min(stream.bytesLoaded / stream.bytesTotal, xPos / $element.width()) * stream.durationEstimate)
  console.log 'seek to:' + needSeek
  stream.setPosition needSeek
  return

audioSeekingHandler = () ->
  jQuery(document).on 'click', '.sf-audio-player', (event) ->
    $this = jQuery(this)
    $postHeader = $this.closest('.post-header')
    $playback = jQuery('.header-wrap .line .audio-playback', $postHeader)
    if $playback.is('.playing')
      audioScrub $this, event.pageX
    else
      console.log 'audio not playing'
    false
  return

audioPlayback = () ->
  jQuery(document).on 'click', '.audio-playback', (event) ->
    $this = jQuery(this)
    if !$this.is('.playing')
      if typeof window.scStreams != 'undefined'
        jQuery.each window.scStreams, (index, stream) ->
          if index != $this.data('track-index')
            window.scStreams[index].pause()
          return
      jQuery('.audio-playback.playing').removeClass 'playing'
      $this.addClass 'playing'
    else
      $this.removeClass 'playing'
    if typeof window.scStreams != 'undefined'
      window.scStreams[$this.data('track-index')].togglePause()
    false
  return

module.exports = {
  audioPlayback: audioPlayback
}