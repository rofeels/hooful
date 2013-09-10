
class Hooful.Views.HoofulsMeetGroupTalk extends Backbone.View

  template: JST['hoofuls/group_member_talk']
  tagName: 'div'

  events:
    'keyup #gSend': 'enterSend'
    'keyup .groupSearch #gSearch': 'searchMember'
    'click .groupSend .blue.btn': 'sendTalk'

  initialize: ->
    _.bindAll(this, 'updateTalk','updateMem','enterSend')
    @getContents()
    @isSending = false
    that = @
    socket.emit "addgroupuser", that.options.mcode, userid
    socket.on "updatestate", (data) -> that.updateState(data)
    socket.on "updatechat", @updateTalk
    socket.on "updatemem", @updateMem
    socket.on "updateinfo", @updateInfo

  render: ->
    $(@el).attr("id","groupTalk").attr("mcode", @options.mcode).html(@template())
    this
  enterSend: (e) ->
    if e.keyCode == 13 or e.keyCode == 3
      @sendTalk()

  sendTalk: ->
    if $('#gSend').val() is ""
      alert "메세지를 입력해 주세요."
    else
      if @isSending is false
        @isSending = true
        @grouptalks = new Hooful.Collections.MeetGroupTalks()
        @grouptalks.fetch(
          data: {mcode: $('#groupTalk').attr('mcode') , mUserid: userid, message: $('#gSend').val(), lastTalk: $('.groupBody .talk:last').attr("tid"),type:"send"}
          type: "POST"
          success: =>
            $('#gSend').val ""
            @isSending = false
        )
      else
        alert "메세지를 전송중입니다."

  updateTalk: ->
    @grouptalks = new Hooful.Collections.MeetGroupTalks()
    @grouptalks.fetch(
      data: {mcode: @options.mcode,  lastTalk: $('.groupBody .talk:last').attr("tid"),type:"talks"}
      type: "POST"
      success: =>
        group_msg = new Hooful.Views.HoofulsMeetGroupMessage(@grouptalks)
        $('.groupBody .talkWrap').append(group_msg.render().el)
        
        totalHeight = 0
        $(".groupBody .talkWrap ul").each ->
          totalHeight += $(this).height()
        $(".groupBody").scrollTop totalHeight
    )

  updateMem: ->
    @groupmem = new Hooful.Collections.MeetGroupTalks()
    @groupmem.fetch(
      data: {mcode: @options.mcode, keyword: $('#gSearch').val(), lastTalk: $('.groupBody .talk:last').attr("tid"), type:"members"}
      type: "GET"
      success: =>
        group_msg = new Hooful.Views.HoofulsMeetGroupMessage(@groupmem)
        $('.groupBody .talkWrap').append(group_msg.render().el)
        totalHeight = 0
        $(".groupBody .talkWrap ul").each ->
          totalHeight += $(this).height()
        $(".groupBody").scrollTop totalHeight
        group_members = new Hooful.Views.HoofulsMeetGroupMember(@groupmem)
        $('.groupMember ul').remove()
        $('.groupMember').html(group_members.render().el)
        $('.groupContents .groupInfo .partice').text(@groupmem.models[0].get(0).length)
    )

  updateState: (e) ->
   $(".groupMember .profile i").removeClass("on")
   for i of e
      uid = e[i]+""
      uid = uid.replace /^\s+|\s+$/g, ""
      uid = Base64.encode64(uid+"#hUser")
      $(".groupMember .profile[uid='"+uid+"'] i").addClass("on")

  getContents: ->
    @groupall = new Hooful.Collections.MeetGroupTalks()
    @groupall.fetch(
      data: {mcode: @options.mcode, type:"all"}
      type: "GET"
      success: =>
        group_members = new Hooful.Views.HoofulsMeetGroupMember(@groupall)
        $('.groupMember ul').remove()
        $('.groupMember').html(group_members.render().el)
        group_msg = new Hooful.Views.HoofulsMeetGroupMessage(@groupall)
        $('.groupBody .talkWrap').html(group_msg.render().el)
        
        totalHeight = 0
        $(".groupBody .talkWrap ul").each ->
          totalHeight += $(this).height()
        $(".groupBody").scrollTop totalHeight
        socket.emit "addgroupuser", @options.mcode, userid
    )

class Hooful.Views.HoofulsMeetGroupMember extends Backbone.View

  template: JST['hoofuls/group_member']
  tagName: 'ul'

  initialize: ->

  render: ->
    $(@el).html(@template(members: @options.models[0].get(0)))
    this

class Hooful.Views.HoofulsMeetGroupMessage extends Backbone.View

  template: JST['hoofuls/group_message']
  tagName: 'ul'

  events:
    'click .more': 'loadPrev'

  initialize: ->
    @isSending = false

  render: ->
    $(@el).html(@template(talks: @options.models[1].get(0)))
    this

  loadPrev: ->
    if @isSending is false
      @isSending = true
      @grouptalks = new Hooful.Collections.MeetGroupTalks()
      @grouptalks.fetch(
        data: {mcode: $('#groupTalk').attr('mcode'), type:"talks", firstTalk: $('.groupBody .talk:first').attr("tid")}
        type: "GET"
        success: =>
          $('.groupBody .more').remove()
          group_msg = new Hooful.Views.HoofulsMeetGroupMessage(@grouptalks)
          $('.groupBody .talkWrap').prepend(group_msg.render().el)
          @isSending = false
      )
    else
      alert "대화 내용을 불러오는 중입니다."
