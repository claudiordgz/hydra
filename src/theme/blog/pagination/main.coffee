
next = require "./next-post"
recent = require "./recent-post"
infinite = require "./infinite-scroll"

module.exports = {
  infiniteScrollHandler: infinite.infiniteScrollHandler,
  nextPost: next.nextPost,
  getRecentPosts: recent.getRecentPosts
}