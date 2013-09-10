class Hooful.Views.HoofulsHooParticipantsWrap extends Backbone.View

  template: JST['hoofuls/participants_wrap']
  tagName: 'div'  

  initialize: ->
    @isSending = false
    @type = "participants"
    @particelist = new Hooful.Collections.Hoopartices()
    @particelist.fetch(
      data: {mCode: $('#mCode').val() , type: @type, size: 0}
      type: "GET"
      success: =>
        hoopartice = new Hooful.Views.HoofulsHoopatice( @particelist)
        $('dl.mParticipants dd > div > div.'+@type ).html(hoopartice.render().el)
    )
    $("dl.mParticipants dt span").click @particeList
    
  render: ->
    $(@el).html(@template())
    this

  particeList: (event) ->
    $('dl.mParticipants dt span').removeClass("active")
    $('dl.mParticipants dd > div > div').hide()
    type = $(event.target).attr("class")
    $(event.target).addClass("active")
    $('dl.mParticipants dd > div > div.'+type).show()

class Hooful.Views.HoofulsHoopatice extends Backbone.View

  template: JST['hoofuls/hoo_partice']
  tagName: 'div'

  initialize: ->
    _.bindAll(this,'scrollDetect')
    @isSending = false
    if window.addEventListener
      window.addEventListener "scroll", @scrollDetect, false
    else if window.attachEvent 
      window.attachEvent "onscroll", @scrollDetect  


  render: ->
    $(@el).html(@template(partice: @options))
    this

  loadNext:->
    if @isSending is false
      @isSending = true
      type = $('dl.mParticipants dd > div > div:visible').attr "class"
      size =  $('dl.mParticipants dd > div > div.'+type+' div .profile').length
      @particelist = new Hooful.Collections.Hoopartices()
      @particelist.fetch(
        data: {mCode: $('#mCode').val() , size: size, type: type}
        type: "GET"
        success: =>
          $('dl.mParticipants dd > div > div.'+type+' div .more').remove()
          hoopartice = new Hooful.Views.HoofulsHoopatice( @particelist)
          $('dl.mParticipants dd > div > div.'+type).append(hoopartice.render().el)
          @isSending = false
      )
    else

  scrollDetect: (e)->
    e.stopImmediatePropagation();
    scrollTop = $(window).scrollTop()
    documentHeight = $(document).height()
    windowHeight = $(window).height()
    scrollBottom = scrollTop + windowHeight
    if scrollBottom is documentHeight
      @loadNext()