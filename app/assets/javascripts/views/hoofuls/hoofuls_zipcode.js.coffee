class Hooful.Views.HoofulsZipcodeDong extends Backbone.View

  template: JST['hoofuls/zipcode_dong']
  tagName: 'ul'
  events:
    'click li': 'putZipcode'
    
  initialize: ->
    
  render:(size) ->
    $(@el).html(@template(zipcode: @options.models))
    this
    
  putZipcode: (e) ->
    unless $(e.currentTarget).hasClass("none")
      $("#local.hInput").val($(e.currentTarget).text())
      $(".bgzipcode").hide()
      $(".popzipcode").hide()
      $("#local.hInput").parent().parent().addClass("set")