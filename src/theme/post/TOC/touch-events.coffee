

touchTOC =
  init: () ->
    this.setupTOCSwipe()

# Get the offset from the top to the post content, including the sticky header
# @return (Object) { shouldWeAddTopOffset - True if the post-header is visible and
#                     bigger than the sticky fixed header
#                    offsetToTopPixels - Pair of Max between height of the sticky fixed
#                     header and 0 if no sticky fixed header visible
#                    newTOCHeightPixels - The distance between the current position and
#                     the end of the document so that the TOC doesn't overflow
#                   }
  getOffsetToTopToPostContent: () ->
    postHeader = document.getElementsByClassName('post-header')[0];
    drawerContainingContainer = document.getElementsByClassName('mdl-layout__container')[0]
    stickyHeader = document.getElementsByClassName('header header-standard fixed-top')[0];
    extraOffset = if stickyHeader then Math.max(stickyHeader.clientHeight, stickyHeader.offsetHeight, stickyHeader.scrollHeight) else 0
    return {
    shouldWeAddTopOffset: postHeader.getBoundingClientRect().bottom <= extraOffset,
    offsetToTopPixels: extraOffset.toString(),
    newTOCHeightPixels: drawerContainingContainer.getBoundingClientRect().bottom.toString()  + 'px'
    }

# Sets the correct position for the TOC and the correct Height.
# Will set the position to fixed if there is no post-header visible in sight
# otherwise it will be absolute
  handleTOCSwipeOpen: (ev) ->
    className = 'mdl-layout__drawer'
    drawer = document.getElementsByClassName(className)[0]
    if !/is-visible/.test(drawer.className)
      calculatedDimensions = this.getOffsetToTopToPostContent()
      topOffset = if calculatedDimensions.shouldWeAddTopOffset then  + calculatedDimensions.offsetToTopPixels + 'px' else '0'
      positionSwitch = if calculatedDimensions.shouldWeAddTopOffset then ' position: fixed;' else 'position: absolute;'
      drawer.style.cssText += positionSwitch + ' top: ' + topOffset + ';'
      drawer.style.cssText += 'height: ' + calculatedDimensions.newTOCHeightPixels + ';'
      drawer.className += ' is-visible'
    return

  setupTOCSwipe: () ->
    showDrawer = document.getElementsByClassName('page-content')[0]
    mcShowDrawerSwipe = new Hammer(showDrawer, {
      cssProps: {
        userSelect: true
      }
    })
    mcShowDrawerSwipe.on("swiperight", this.handleTOCSwipeOpen.bind(this))




module.exports = {
  touchTOC: touchTOC
}