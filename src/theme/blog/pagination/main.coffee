
next = require "./next-post"
recent = require "./recent-post"
infinite = require "./infinite-scroll"
refresh = require "./refresh-theme"

module.exports = {
  infiniteScrollHandler: infinite.infiniteScrollHandler,
  nextPost: next.nextPost,
  getRecentPosts: recent.getRecentPosts,
  refreshTheme: refresh.refreshTheme
}