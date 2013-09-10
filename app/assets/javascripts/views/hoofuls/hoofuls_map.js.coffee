class Hooful.Views.HoofulsMap extends Backbone.View
  template: JST['hoofuls/map']
  tagName: 'div'
  
  events:
    'click #mAddress': 'addSet'
    'blur #mAddress': 'removeSet'

  initialize: ->

  render: ->
    $(@el).addClass("map").html(@template())
    this

  addSet: ->
    $('.map_search').addClass('set')
  removeSet: ->
    if $('#mAddress').val()
      $('.map_search').addClass('set')
    else
      $('.map_search').removeClass('set')
