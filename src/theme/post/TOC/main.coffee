util = require "../../common/util"

createTOC = () ->
  pageContent = document.getElementsByClassName('post-content')[0]
  navigationLinks = document.getElementsByClassName('mdl-navigation')[0]
  postTitle = document.getElementsByClassName('post-title')[0]
  navigationTitle = document.getElementsByClassName('mdl-layout-title')[0]
  if navigationTitle.innerText
    navigationTitle.innerText = postTitle.innerText
  else if navigationTitle.innerHTML
    navigationTitle.innerHTML = postTitle.innerHTML
  i = 0
  childNode = undefined
  while i <= pageContent.children.length
    childNode = pageContent.children[i]
    if childNode
      if childNode.tagName == 'H2'
        textToSlugify = if childNode.innerText then childNode.innerText else if childNode.innerHTML then childNode.innerHTML else childNode.textContent
        text = util.slugify(textToSlugify)
        aTag = document.createElement('a')
        aTag.setAttribute 'name', text
        pageContent.insertBefore aTag, childNode
        linkToTag = document.createElement('a')
        linkToTag.innerHTML = textToSlugify
        linkToTag.className = 'mdl-navigation__link'
        linkToTag.href = '#' + text
        navigationLinks.appendChild linkToTag
        i += 1
    i++

stickyTOC = () ->
  util.addEvent window, 'scroll', (event) ->
    className = 'mdl-layout__drawer'
    drawer = document.getElementsByClassName(className)[0]
    scrollY = document.body.scrollTop
    if scrollY >= 585
      if !/fixed/.test(drawer.className)
        drawer.className += ' fixed'
    else
      drawer.className = className
    return

init = () ->
  createTOC()
  stickyTOC()

module.exports = {
  init: init
}