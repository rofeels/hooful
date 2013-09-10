class Hooful.Views.HoofulsGuestbookWrap extends Backbone.View

  template: JST['hoofuls/guestbook_wrap']
  tagName: 'div'

  initialize: ->
    @isSending = false
    
    if $('#hUserinfo').attr('visitor_id')    
      @guestwrite = new Hooful.Collections.CommonMeet()
      @guestwrite.fetch(
        data: {hostid: $('#hUserinfo').attr('userid'),guestid: $('#hUserinfo').attr('visitor_id')}
        success: =>
          common_meet = new Hooful.Views.HoofulsGuestbookWrite(@guestwrite)
          $('#uGuestbook dd .guestbook_write').html(common_meet.render().el)
      )

    @guestbook = new Hooful.Collections.Guestbooks()
    @guestbook.fetch(
      data: {gHostid: $('#hUserinfo').attr('userid')}
      type: "GET"
      success: =>
        if @guestbook.models.length < 6
           $('#uGuestbook dt .number').text "("+ @guestbook.models.length + ")"
        else
          $('#uGuestbook dt .number').text "("+ @guestbook.models[@guestbook.models.length-1].get('prev') + ")"
        guestbook = new Hooful.Views.HoofulsGuestbook(@guestbook)
        $('#uGuestbook dd .guestbook_list').html(guestbook.render().el)
        $('.userLine').css('height',($('#hContainer').height()-395)+'px')
        $('.userLine').css('bottom','-'+($('#hContainer').height()-395)+'px')
        $(window).resize ->
          $('.userLine').css('height',($('#hContainer').height()-395)+'px')
          $('.userLine').css('bottom','-'+($('#hContainer').height()-395)+'px')
    )

  render:(size) ->
    $(@el).html(@template())
    this

class Hooful.Views.HoofulsGuestbook extends Backbone.View

  template: JST['hoofuls/guestbook']
  tagName: 'div'
  events:
    'click .more': 'loadPrev'

  initialize: ->
    @isSending = false

  render:(size) ->
    $(@el).html(@template(guestbooks: @options, vuserid: $('#hUserinfo').attr('visitor_id'), vpicture:$('#hUserinfo').attr('visitor_picture'), vname: $('#hUserinfo').attr('visitor_name')))
    this

  loadPrev: ->
    if @isSending is false
      @isSending = true
      @guestbook = new Hooful.Collections.Guestbooks()
      @guestbook.fetch(
        data: {gHostid: $('#hUserinfo').attr('userid'),gUserid: $('#hUserinfo').attr('visitorsid'), lastTalk: $('#uGuestbook dd .guestbook_each:last').attr("gid")}
        type: "GET"
        success: =>
          $('.guestbook_list .more').remove()
          guestbook = new Hooful.Views.HoofulsGuestbook(guestbooks:@guestbook, vuserid: $('#hUserinfo').attr('visitor_id'), vpicture:$('#hUserinfo').attr('visitor_picture'), vname: $('#hUserinfo').attr('visitor_name'))
          $('#uGuestbook dd .guestbook_list').append(guestbook.render().el)
          $('.userLine').css('height',($('#hContainer').height()-395)+'px')
          $('.userLine').css('bottom','-'+($('#hContainer').height()-395)+'px')
          $(window).resize ->
            $('.userLine').css('height',($('#hContainer').height()-395)+'px')
            $('.userLine').css('bottom','-'+($('#hContainer').height()-395)+'px')
          @isSending = false
      )
    else
      alert "댓글을 불러오는 중입니다."

class Hooful.Views.HoofulsGuestbookWrite extends Backbone.View

  template: JST['hoofuls/guestbook_write']
  tagName: 'div'
  events:
    'click .btnPost': 'reviewWrite'
    'click .commonMeet li': 'fillForm'

  initialize: ->
    @isSending = false

  render:(size) ->
    $(@el).html(@template(host: $('#hUserinfo').attr('userid'), hostname: $('#hUserinfo').attr('username'), userid: $('#hUserinfo').attr('visitor_id'), picture:$('#hUserinfo').attr('visitor_picture'), name: $('#hUserinfo').attr('visitor_name'), common: @options))
    this

  fillForm: (event)->
    index = $('.commonMeet .dropdown-menu li').index($(event.target))
    $('.mmTitle').text @options.models[index].get('mTitle')
    $('.commonMeet .dropdown-menu li').removeClass("active")
    $(event.target).addClass("active")

  reviewWrite: ->
    if $('#gComment').val() is ""
      alert "댓글 내용을 입력해 주세요"
    else
      if @isSending is false
        @isSending = true
        @guestbook = new Hooful.Collections.Guestbooks()
        @guestbook.fetch(
          data: {gHostid: $('#hUserinfo').attr('userid'), gMsg: $('#gComment').val(),gUserid: $('#hUserinfo').attr('visitor_id'), firstTalk: $('#uGuestbook dd .guestbook_each:first').attr("gid"), mCode: $('.commonMeet .dropdown-menu li.active').attr("code"), mTitle: $('.commonMeet .dropdown-menu li.active').text(), mCategory: $('.commonMeet .dropdown-menu li.active').attr("cat") }
          type: "POST"
          success: =>
            guestbook = new Hooful.Views.HoofulsGuestbook(@guestbook)
            $('#uGuestbook dd .guestbook_list').prepend(guestbook.render().el)
            $('#gComment').val ""
            $('.userLine').css('height',($('#hContainer').height()-395)+'px')
            $('.userLine').css('bottom','-'+($('#hContainer').height()-395)+'px')
            $(window).resize ->
              $('.userLine').css('height',($('#hContainer').height()-395)+'px')
              $('.userLine').css('bottom','-'+($('#hContainer').height()-395)+'px')
            @isSending = false
        )
      else
        alert "댓글을 전송중입니다."
