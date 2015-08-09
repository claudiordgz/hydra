util = require "../../common/util"

contentsTOC =
  init: () ->
    this.setTitle()
    this.setContent()

  setTitle: () ->
    postTitle = document.getElementsByClassName('post-title')[0]
    navigationTitle = document.getElementsByClassName('mdl-layout-title')[0]
    if navigationTitle.innerText
      navigationTitle.innerText = postTitle.innerText
    else if navigationTitle.innerHTML
      navigationTitle.innerHTML = postTitle.innerHTML

  setContent: () ->
    results = document.querySelectorAll('h2,h3,h4,h5,h6');
    navigationLinks = document.getElementsByClassName('mdl-navigation')[0]
    for childNode in results
      aLink = this.processDomChildTag(navigationLinks, childNode)
      navigationLinks.appendChild aLink if aLink
    return

  processDomChildTag: (navigationLinks, childNode) ->
    childNodeStr = if childNode then if childNode.className then childNode.className.toString() else null
    tagName = childNode.tagName
    if childNode && childNodeStr != "search-label" && childNodeStr != "box-title"
      if tagName == 'H2' || tagName == 'H3' || tagName == 'H4' || tagName == 'H5' || tagName == 'H6'
        textToSlugify = if childNode.innerText then childNode.innerText else if childNode.innerHTML then childNode.innerHTML else childNode.textContent
        slugifiedText = util.slugify(textToSlugify)
        childNode.outerHTML += this.createAnchor(slugifiedText).outerHTML
        aLink = this.createLinkToAnchor(slugifiedText, textToSlugify, tagName)
        return aLink
    return null

  createAnchor: (slugifiedText) ->
    aTag = document.createElement('a')
    aTag.setAttribute 'name', slugifiedText
    return aTag

  closeDrawer: () ->
    className = 'mdl-layout__drawer'
    drawer = document.getElementsByClassName(className)[0]
    if /is-visible/.test(drawer.className)
      drawer.className = className

  createLinkToAnchor: (slugifiedText, Text, tagName) ->
    linkToTag = document.createElement('a')
    linkToTag.innerHTML = Text
    linkToTag.className = 'mdl-navigation__link toc' + tagName
    linkToTag.href = '#' + slugifiedText
    linkToTag.onclick = this.closeDrawer.bind(this)
    return linkToTag

module.exports = {
  contentsTOC: contentsTOC
}