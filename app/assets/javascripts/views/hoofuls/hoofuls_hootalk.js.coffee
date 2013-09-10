class Hooful.Views.HoofulsHooTalkWrap extends Backbone.View

  template: JST['hoofuls/hoo_talk_wrap']
  tagName: 'div'  
  events:
    'click #hootalkbtn': 'hooTalk'

  initialize: ->
    if typeof userid isnt "string" or userid is ""
      userid = ""

    @isSending = false
    _.bindAll(this,'hooTalk')
    @hootalk = new Hooful.Collections.HooTalks()
    @hootalk.fetch(
      data: {mCode: $('#mCode').val() , mUserid: userid , mHost: $('#mHost').val()}
      type: "GET"
      success: =>
        hoo_talk = new Hooful.Views.HoofulsHooTalk(@hootalk)
        $('.Hootalk .talklist').html(hoo_talk.render().el)
        $(".Hootalk .talklist").scrollTop 0 
    )
    

  render: ->
    $(@el).html(@template(userpic:userpic))
    this

  hooTalk: ->
    if typeof userid is "string" and userid isnt ""
      if $('#hootalkInput').val() is ""
        alert "메세지를 입력해 주세요"
      else
        if @isSending is false
          @isSending = true
          @hootalk = new Hooful.Collections.HooTalks()
          @hootalk.fetch(
            data: {mCode: $('#mCode').val() , mUserid: userid , mHost: $('#mHost').val(), mMsg: $('#hootalkInput').val(),firstTalk: $('.Hootalk .talks:first').attr("tid")}
            type: "POST"
            success: =>
              hoo_talk = new Hooful.Views.HoofulsHooTalk(@hootalk)
              $('.Hootalk .talklist').prepend(hoo_talk.render().el)
              $(".Hootalk .talklist").scrollTop 0 
              $('#hootalkInput').val ""
              @isSending = false
          )
        else
          alert "메세지를 전송중입니다."
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/"+$('#mCode').val())


class Hooful.Views.HoofulsHooTalk extends Backbone.View

  template: JST['hoofuls/hoo_talk']
  tagName: 'div'

  events:
    'click .more': 'loadPrev'
  initialize: ->
    @isSending = false

  render: ->
    $(@el).html(@template(talks: @options))
    this
  loadPrev: ->
    if @isSending is false
      @isSending = true
      @hootalk = new Hooful.Collections.HooTalks()
      @hootalk.fetch(
        data: {mCode: $('#mCode').val() , mUserid: userid , mHost: $('#mHost').val(),lastTalk: $('.Hootalk .talks:last').attr("tid")}
        type: "GET"
        success: =>
          $('.Hootalk .more').remove()
          hoo_talk = new Hooful.Views.HoofulsHooTalk(@hootalk)
          $('.Hootalk .talklist').append(hoo_talk.render().el)
          @isSending = false
      )
    else
      alert "후톡을 불러오는 중입니다."
