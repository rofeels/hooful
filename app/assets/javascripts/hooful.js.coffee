window.Hooful =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    new Hooful.Routers.Hoofuls()

    startingUrl = "/"

    unless window.history and window.history.pushState
      window.location.hash = window.location.pathname.replace(startingUrl, "")
      startingUrl = window.location.pathname
    Backbone.history.start
      pushState: true
      root: startingUrl


$(document).ready ->
  Hooful.initialize()
