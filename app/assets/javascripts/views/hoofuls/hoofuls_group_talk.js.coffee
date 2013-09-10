class Hooful.Views.HoofulsGroupTalk extends Backbone.View

  template: JST['hoofuls/group_talk']
  tagName: 'div'

  events:
    'keyup #gSend': 'enterSend'
    'keyup .groupSearch #gSearch': 'searchMember'
    'click .groupSend .blue.btn': 'sendTalk'
    'click .mCancel': 'particeCancel'
    'click .mEdit': 'editInfo'

  initialize: ->
    _.bindAll(this, 'updateTalk','updateMem','updateInfo','enterSend')
    @getContents()
    @isSending = false
    that = @
    socket.emit "addgroupuser", that.options.id, userid
    socket.on "updatechat", @updateTalk
    socket.on "updatemem", @updateMem
    socket.on "updateinfo", @updateInfo

  render: ->
    $(@el).attr("id","groupTalk").attr("_id", @options.id).attr("title", @options.title).attr("date", @options.date).attr("member", @options.member).attr("partice", @options.partice).attr("host", @options.host).attr("category", @options.category).attr("company", @options.company).html(
      @template(
        id: @options.id,
        title: @options.title,
        date: @options.date,
        member: @options.member,
        partice: @options.partice,
        host: @options.host,
        category: @options.category,
        company: @options.company,
        company_title: @options.company_title,
        company_price: @options.company_price,
        company_image: @options.company_image,
        host_name: @options.host_name,
        host_picture: @options.host_picture,
        host_link: @options.host_link,
        host_members: @options.host_members
      )
    )
    this
  enterSend: (e) ->
    if e.keyCode == 13 or e.keyCode == 3
      @sendTalk()

  searchMember: ->
    @grouptalks = new Hooful.Collections.GroupTalks()
    @grouptalks.fetch(
      data: {id: @options.id, keyword: $('#gSearch').val(),type:"search"}
      type: "GET"
      success: =>
        group_members = new Hooful.Views.HoofulsGroupMember(@grouptalks)
        $('.groupMember ul').remove()
        $('.groupMember').html(group_members.render().el)
    )

  particeCancel: ->
    $('#groupConfirm').remove()
    cancel_confirm = new Hooful.Views.HoofulsGroupConfirm(id: @options.id, category: @options.category)
    $('body').append(cancel_confirm.render().el)
    $('#groupConfirm').modal()

  sendTalk: ->
    if $('#gSend').val() is ""
      alert "메세지를 입력해 주세요."
    else
      if @isSending is false
        @isSending = true
        @grouptalks = new Hooful.Collections.GroupTalks()
        @grouptalks.fetch(
          data: {id: $('#groupTalk').attr('_id') , mCode: $('#mCode').val() , mUserid: userid, message: $('#gSend').val(), lastTalk: $('.groupBody .talk:last').attr("tid"),type:"send"}
          type: "POST"
          success: =>
            $('#gSend').val ""
            @isSending = false
        )
      else
        alert "메세지를 전송중입니다."

  updateTalk: ->
    @grouptalks = new Hooful.Collections.GroupTalks()
    @grouptalks.fetch(
      data: {id: @options.id,  lastTalk: $('.groupBody .talk:last').attr("tid"),type:"talks"}
      type: "POST"
      success: =>
        group_msg = new Hooful.Views.HoofulsGroupMessage(@grouptalks)
        $('.groupBody .talkWrap').append(group_msg.render().el)
        
        totalHeight = 0
        $(".groupBody .talkWrap ul").each ->
          totalHeight += $(this).height()
        $(".groupBody .talkWrap").scrollTop totalHeight
    )

  updateMem: ->
    @groupmem = new Hooful.Collections.GroupTalks()
    @groupmem.fetch(
      data: {id: @options.id, keyword: $('#gSearch').val(), lastTalk: $('.groupBody .talk:last').attr("tid"), type:"members"}
      type: "GET"
      success: =>
        group_msg = new Hooful.Views.HoofulsGroupMessage(@groupmem)
        $('.groupBody .talkWrap').append(group_msg.render().el)
        totalHeight = 0
        $(".groupBody .talkWrap ul").each ->
          totalHeight += $(this).height()
        $(".groupBody .talkWrap").scrollTop totalHeight
        group_members = new Hooful.Views.HoofulsGroupMember(@groupmem)
        $('.groupMember ul').remove()
        $('.groupMember').html(group_members.render().el)
        $('.groupContents .groupInfo .partice').text(@groupmem.models[0].get(0).length)

    )
  updateInfo: ->
    @group = new Hooful.Collections.Groups()
    @group.fetch(
      data: {gId: $('#groupTalk').attr('_id'), type: "getInfo"}
      type: "POST"
      success: =>
        if @group.models[0].get('_id')
          $('#groupTalk').attr('_id', @group.models[0].get('_id'))
          $('#groupTalk').attr('title', @group.models[0].get('gTitle'))
          $('#groupTalk').attr('date', @group.models[0].get('gDate'))
          $('#groupTalk').attr('host', @group.models[0].get('gHost'))
          $('#groupTalk').attr('member', @group.models[0].get('gMembers'))
          $('#groupTalk').attr('partice', @group.models[0].get('gPartices'))
          $('#groupTalk').attr('company', @group.models[0].get('mCode'))
          $('.groupContents .groupCompany .title').text(@group.models[0].get('company_title'))
          $('.groupContents .groupCompany dd').css('background', "url('http://d3o755op057jl1.cloudfront.net/meetpic/thumb/"+@group.models[0].get('company_image')+"')")
          $('.groupContents .groupCompany a').attr('href', "/"+@group.models[0].get('mCode'))
          $('.groupContents .groupTitle .title').text(@group.models[0].get('gTitle'))
          $('.groupContents .groupInfo .date').text(@group.models[0].get('gDate')[0..9])
          $('.groupContents .groupInfo .member').text(@group.models[0].get('gMembers'))
          $('.groupContents .groupInfo .partice').text(@group.models[0].get('gPartices'))
    )
  getContents: ->
    @groupall = new Hooful.Collections.GroupTalks()
    @groupall.fetch(
      data: {id: @options.id, type:"all"}
      type: "GET"
      success: =>
        group_members = new Hooful.Views.HoofulsGroupMember(@groupall)
        $('.groupMember ul').remove()
        $('.groupMember').html(group_members.render().el)
        group_msg = new Hooful.Views.HoofulsGroupMessage(@groupall)
        $('.groupBody .talkWrap').html(group_msg.render().el)
        
        totalHeight = 0
        $(".groupBody .talkWrap ul").each ->
          totalHeight += $(this).height()
        $(".groupBody .talkWrap").scrollTop totalHeight
    )
  editInfo: ->
    $("#groupModal").remove()
    group_edit = new Hooful.Views.HoofulsGroupEdit()
    $('body').append(group_edit.render('').el)
    calendar = new Hooful.Views.HoofulsCalendar()
    $('#groupCalendar').append(calendar.render($('#groupCalendar').attr("target"), '').el)
    $('#groupCalendar .calendar').css("display","inline-block")
    @company = new Hooful.Collections.Company()
    @company.fetch(
      data: {company: @options.category}
      success: =>
        company = new Hooful.Views.HoofulsCompanyList(@company)
        $('#groupCompany .dropdown-menu').html(company.render().el)
		
        if $("#selectCompany").val() isnt ""
          code = $("#selectCompany").val()
          target = $("#groupCompany .dropdown-menu li[code="+code+"]")
          if target.length > 0
            $("#groupCompany .dropdown-toggle").html(target.text()+"<span class=\"caret\"></span>")
            $(target).addClass("active")
    )  
    $("#groupModal").modal()

class Hooful.Views.HoofulsGroupMember extends Backbone.View

  template: JST['hoofuls/group_member']
  tagName: 'ul'

  initialize: ->

  render: ->
    $(@el).html(@template(members: @options.models[0].get(0)))
    this

class Hooful.Views.HoofulsGroupMessage extends Backbone.View

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
      @grouptalks = new Hooful.Collections.GroupTalks()
      @grouptalks.fetch(
        data: {id: $('#groupTalk').attr('_id'), type:"talks", firstTalk: $('.groupBody .talk:first').attr("tid")}
        type: "GET"
        success: =>
          $('.groupBody .more').remove()
          group_msg = new Hooful.Views.HoofulsGroupMessage(@grouptalks)
          $('.groupBody .talkWrap').prepend(group_msg.render().el)
          @isSending = false
      )
    else
      alert "대화 내용을 불러오는 중입니다."

class Hooful.Views.HoofulsGroupEdit extends Backbone.View
  template: JST['hoofuls/group_edit']
  tagName: 'div'

  events:
    'click #editComplete': 'editComplete'

  initialize: ->
    @isSending = false

  render: (target)->
    target = (if target then target else @el)
    $(target).addClass("modal hide fade").attr("id","groupModal").html(@template(mcode:$('#groupTalk').attr('company'), id:$('#groupTalk').attr('_id'), title:$('#groupTalk').attr('title'), date:$('#groupTalk').attr('date'), company:$('#groupTalk').attr('company')))
    this

  editComplete: ->
    if  @isSending is false
      if $('#groupName').val()
        @isSending = true
        @group = new Hooful.Collections.Groups()
        @group.fetch(
          data: {gId: $('#groupTalk').attr('_id'), gTitle: $('#groupName').val(),  mDate: $('#particeDate').val(),  mCode: $('#selectCompany').val(), mUserid: userid, type: "editGroup"}
          type: "POST"
          success: =>
            $('#groupTalk').remove()
            #alert JSON.stringify(@group, null, "\t").replace(/\n/g, "\n")
            if @group.models[0].get('_id')
              $('#groupTalk').attr('_id', @group.models[0].get('_id'))
              $('#groupTalk').attr('title', @group.models[0].get('gTitle'))
              $('#groupTalk').attr('date', @group.models[0].get('gDate'))
              $('#groupTalk').attr('host', @group.models[0].get('gHost'))
              $('#groupTalk').attr('member', @group.models[0].get('gMembers'))
              $('#groupTalk').attr('partice', @group.models[0].get('gPartices'))
              $('#groupTalk').attr('company', @group.models[0].get('mCode'))
              group_talk = new Hooful.Views.HoofulsGroupTalk(
                id: @group.models[0].get('_id'),
                title: @group.models[0].get('gTitle'),
                date: @group.models[0].get('gDate'),
                member: @group.models[0].get('gMembers'),
                partice: @group.models[0].get('gPartices'),
                host: @group.models[0].get('gHost'),
                category:@group.models[0].get('gCategory'),
                company:@group.models[0].get('mCode'),
                company_title:@group.models[0].get('company_title'),
                company_image:@group.models[0].get('company_image'),
                company_price:@group.models[0].get('company_price'),
                host_name:@group.models[0].get('host_name'),
                host_link:@group.models[0].get('host_link'),
                host_members:@group.models[0].get('host_members'),
                host_picture:@group.models[0].get('host_picture')
              )
              $('.hcGroupList').html(group_talk.render().el)
              $('#modalResponse').click().remove()
            else
              event.stopPropagation();
              alert "오류가 발생했습니다. 다시 시도해 주세요."
            @isSending = false
        )
      else
        event.stopPropagation();
        alert "그룹 제목을 입력해 주세요."
    else
      event.stopPropagation();
      alert "그룹을 수정중입니다. 잠시만 기다려 주세요."  


class Hooful.Views.HoofulsGroupConfirm extends Backbone.View

  template: JST['hoofuls/group_cancel']
  tagName: 'div'

  events:
    'click #confirm': 'cancelConfirm'

  initialize: ->
    @isSending = false

  render: ->
    $(@el).addClass("modal hide fade in").attr("id","groupConfirm").attr("hidden","false").html(@template())
    this


  cancelConfirm: ->
    if @isSending is false
      @isSending = true
      @groupout = new Hooful.Collections.Groups()
      @groupout.fetch(
        data: { mUserid: userid, groupId: @options.id, type: "cancel"}
        type: "POST"
        success: =>
          if $('.hcGroupList').length > 0
            gwrap = new Hooful.Views.HoofulsGroupWrap(category: @options.category)
            $('.hcGroupList').html(gwrap.render().el)
            glist = new Hooful.Views.HoofulsGroupList(category: @options.category)
            $('#groupList').html(glist.render().el)
          else
            location.href="/c/"+@options.category
          #$('#groupConfirm').modal('hide')
          $('#modalResponse').click().remove()
          @isSending = false
      )
    else
      alert "참여를 취소하는 중입니다. 잠시만 기다려 주세요."        