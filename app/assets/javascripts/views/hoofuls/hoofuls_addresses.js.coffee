class Hooful.Views.HoofulsAddresses extends Backbone.View
  template: JST['hoofuls/addresses']
  tagName: 'div'
  
  events:
    'click .closebtn': 'close'
    'keypress #dong': 'keycheck'
    'click #btnZipcode': 'search'

  initialize: ->
    $("#local").click ->
      $('.bgzipcode').show()
      $('.popzipcode').show()
  render: ->
    $(@el).addClass("map").html(@template())
    this

  close: ->
    $('.bgzipcode').hide()
    $('.popzipcode').hide()

  keycheck: (e) ->
    if e.keyCode == 13 or e.keyCode == 3
      @search()

  search: ->
    @zipcode = new Hooful.Collections.Zipcodes()
    @zipcode.fetch(
      data: {dong:$("#dong.hInput").val()}
      type: "GET"
      success: =>
        $(".zipcodeResult").show()
        zipcode_dong = new Hooful.Views.HoofulsZipcodeDong(@zipcode)
        $('.zipcodeResult').html(zipcode_dong.render().el)
    )
