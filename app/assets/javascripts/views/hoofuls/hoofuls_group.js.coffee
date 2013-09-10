class Hooful.Views.HoofulsGroupWrap extends Backbone.View
  template: JST['hoofuls/group_wrap']
  events:
    'click #groupMake': 'makeGroup'
    'click #groupReccommend': 'recommendGroup'
    
  initialize: ->

  render: ->
    $(@el).html(@template(userid:$("#hUserNav .name").text()))
    this

  makeGroup: ->
    if typeof (userid) is "string" and userid isnt ""
      @certauth = new Hooful.Collections.CertAuth()
      @certauth.fetch(
        data: {userid: userid}
        type: "GET"
        success: =>
          if @certauth.models[0].get('result') is "faild"
              event.stopPropagation();
              alert "소속인증이 완료되어야 그룹에 참여하실 수 있습니다."
              location.href = "/user/edit"
          else
            $("#groupModal").remove()
            gmake = new Hooful.Views.HoofulsGroupMake(category: @options.category)
            $('body').append(gmake.render('').el)
          
            calendar = new Hooful.Views.HoofulsCalendar()
            $('#groupCalendar').append(calendar.render($('#groupCalendar').attr("target"), '').el)
            $('#groupCalendar .calendar').css("display","inline-block")

            @company = new Hooful.Collections.Company()
            @company.fetch(
              data: {company: @options.category}
              success: =>
                company = new Hooful.Views.HoofulsCompanyList(@company)
                $('#groupCompany .dropdown-menu').html(company.render().el)
            )  
            $("#groupModal").modal()
      )
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/c/"+@options.category)

  recommendGroup: ->
    if typeof (userid) is "string" and userid isnt ""
      @certauth = new Hooful.Collections.CertAuth()
      @certauth.fetch(
        data: {userid: userid}
        type: "GET"
        success: =>
          if @certauth.models[0].get('result') is "faild"
              event.stopPropagation();
              alert "소속인증이 완료되어야 그룹에 참여하실 수 있습니다."
              location.href = "/user/edit"
          else
            $("#groupModal").remove()
            gmake = new Hooful.Views.HoofulsGroupRecommend(category: @options.category)
            $('body').append(gmake.render('').el)
          
            calendar = new Hooful.Views.HoofulsCalendar()
            $('#groupCalendar').append(calendar.render($('#groupCalendar').attr("target"), '').el)
            $('#groupCalendar .calendar').css("display","inline-block")
            $("#groupModal").modal()
            $("#groupModal .reccomend .calendar .date").click (e) ->
              $("#particeDate").val $(e.target).attr("date")
              $("#recommendComplete").click()
            $("#groupModal .withoutDate").click (e) ->
              $("#particeDate").val ""
              $("#recommendComplete").click()
      )
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/c/"+@options.category)


class Hooful.Views.HoofulsGroupList extends Backbone.View
  template: JST['hoofuls/group_card']
  events:
    'click .participate.btn': 'particeGroup'
    'click .more': 'loadMore'
    'click .arrow': 'memberSlide'
    
  initialize: ->
    @isSending = false
    @loadList()

  render: ->
    $(@el).html(@template(group: @group))
    this

  particeGroup: (event) ->
    if typeof (userid) is "string" and userid isnt ""
      $("#groupModal").remove()
      gpartice = new Hooful.Views.HoofulsGroupPartice(gid: $(event.target).attr("gid"),category: @options.category)
      $('body').append(gpartice.render('').el)
      $("#groupModal").modal()
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/"+$('#mCode').val())
      return false

  loadList: ->
    if @isSending is false
      @isSending = true
      @group = new Hooful.Collections.Groups()
      @group.fetch(
        data: {category: @options.category, lastGroup: @options.last}
        type: "GET"
        success: =>
           if (@group.models.length is 0) and (typeof (@options.last) is "undefined")
             $('#groupList').html("생성된 그룹톡이 없습니다.")
             $('.hcGroupList #groupReccommend').hide()
           else
             @render()
           @isSending = false
      )
    else
      alert "그룹을 불러오는 중입니다."

  loadMore: ->
    $('#groupList .more').remove()
    glist = new Hooful.Views.HoofulsGroupList(category: @options.category, last: $('#groupList dl:last ').attr("gid"))
    $('#groupList').append(glist.render().el)
  memberSlide: (event) ->
    direction = $(event.target).attr("class")
    if direction is "arrow right"
      scroll = $(event.target).next(".slide")
      scroll.animate
        scrollLeft: '+=150'
      , 300      
    else
      scroll = $(event.target).next().next(".slide")
      scroll.animate
        scrollLeft: '-=150'
      , 300    
    

class Hooful.Views.HoofulsUserGroup extends Backbone.View

  template: JST['hoofuls/group_card']
  tagName: 'div'

  events:
    'click li.participate .green.btn': 'particeGroup'
    'click .more': 'loadMore'

  initialize: ->
    _.bindAll(this, 'loadGroup')
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadGroup()

  render: ->
    $(@el).html(@template(group: @group, S3ADDR: @S3ADDR))
    this

  loadGroup: ->
    @group = new Hooful.Collections.Groups()
    @group.fetch(
      data: {mUserid: @options.mUserid, lastGroup: $('#uGroup dd ul:last').attr('gid')}
      type: "GET"
      success: =>
        if $('#uGroup dd.group .box ul').length is 0
          if @group.models.length < 5
             $('#uGroup dt .number').text "("+ @group.models.length + ")"
          else
            $('#uGroup dt .number').text "("+ @group.models[@group.models.length-1].get('next') + ")"
         @render()
    )

  loadMore: ->
    if !@isLoading
      user_group = new Hooful.Views.HoofulsUserGroup(mUserid: @options.mUserid)
      $('#uGroup dd .more').remove()
      $('#uGroup dd').append(user_group.render().el)
 
  particeGroup: (event) ->
    location.href="/g/"+$(event.target).attr "gid"
#    if $(event.target).attr("valid") isnt "10"
#      groupId = $(event.target).attr "id"
#      $("#particeStep > .modal-header h3").html("<i class='partice'></i>참가하기")
#      group_hello = new Hooful.Views.HoofulsGroupHello(groupId: groupId)
#      $('#particeStep .modal-body').html(group_hello.render().el)
#    else
#      alert "인원이 마감되었습니다."

class Hooful.Views.HoofulsGroupMake extends Backbone.View

  template: JST['hoofuls/group_make']
  tagName: 'div'

  events:
    'click #makeComplete': 'makeComplete'
    'click .selectDateLater': 'noDate'

  initialize: ->
    @isSending = false

  render: (target)->
    $(@el).addClass("modal hide fade").attr("id","groupModal").html(@template())
    this

  makeComplete: ->
    if  @isSending is false
      if $('#groupName').val()
        @isSending = true
        @group = new Hooful.Collections.Groups()
        @group.fetch(
          data: {gTitle: $('#groupName').val(), mCode: $('#selectCompany').val(), mDate: $('#particeDate').val(), mUserid: userid, category: @options.category, type: "makeGroup"}
          type: "POST"
          success: =>
            if @group.models[0].get('_id')
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
      alert "그룹을 생성중입니다. 잠시만 기다려 주세요."  

  noDate: ->
    $(".date").removeClass("active")
    $("#particeDate").val ""


class Hooful.Views.HoofulsCompanyList extends Backbone.View
  template: JST['hoofuls/reopen']
  tagName: 'div'

  events:
    'click li': 'selectCompany'

  initialize: ->

  render: ->
    $(@el).html(@template(meet: @options))
    this
  
  selectCompany: (event)->
    text = $(event.target).text()
    code = $(event.target).attr "code"
    $("#selectCompany").val code
    $("#groupCompany .dropdown-toggle").html(text+"<span class=\"caret\"></span>")
    $("#groupCompany .dropdown-menu li").removeClass("active")
    $(event.target).addClass("active")


class Hooful.Views.HoofulsGroupPartice extends Backbone.View

  template: JST['hoofuls/group_partice']
  tagName: 'div'

  events:
    'click .btn_next.complete': 'particeComplete'

  initialize: ->
    @isSending = false

  render: (target)->
    $(@el).addClass("modal hide fade").attr("id","groupModal").html(@template())
    this

  particeComplete: ->
    @certauth = new Hooful.Collections.CertAuth()
    @certauth.fetch(
      data: {userid: userid}
      type: "GET"
      success: =>
        if @certauth.models[0].get('result') is "faild"
          event.stopPropagation();
          alert "소속인증이 완료되어야 그룹에 참여하실 수 있습니다."
          location.href = "/user/edit"
        else
          if  @isSending is false
            if $('#groupMessage').val()
              @isSending = true
              @group = new Hooful.Collections.Groups()
              @group.fetch(
                data: {gid: @options.gid, mUserid: userid, message: $('#groupMessage').val(), type: "addMember"}
                type: "POST"
                success: =>
                  if @group.models[0].get('_id')
                    if $('.hcGroupList').length > 0
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
                      $('#groupTalk .NotInGroup').addClass('talkWrap').removeClass('NotInGroup')
                      $('#modalResponse').click().remove()
      
                  else if @group.models[0].get('result') is "faild"
                    event.stopPropagation();
                    alert "인원이 마감되었습니다. 다른 그룹을 선택해 주세요."
                  else
                    event.stopPropagation();
                    alert "오류가 발생했습니다. 다시 시도해 주세요."
                  @isSending = false  
              )
            else
              event.stopPropagation();
              alert "참가인사를 입력해 주세요."
          else
             event.stopPropagation();
            alert "참가인사를 등록중입니다. 잠시만 기다려 주세요."  
    )
class Hooful.Views.HoofulsGroupRecommend extends Backbone.View

  template: JST['hoofuls/group_recommend']
  tagName: 'div'

  events:
    'click #recommendComplete': 'recommendComplete'
    'click .withoutDate': 'noDate'

  initialize: ->
    @isSending = false
  render: (target)->
    $(@el).addClass("modal hide fade").attr("id","groupModal").html(@template())
    this

  recommendComplete: ->
    if @isSending is false
      groupsearching = new Hooful.Views.HoofulsGroupSearching(userid:$("#hUserNav .name").text(),picture: $("#hUserNav .profile").attr("src"))          
      $("#groupReccomendModal").remove()
      $("#groupModal").html(groupsearching.render().el)
      $("#groupModal").attr("id","groupReccomendModal")
      that = @
      setTimeout (->
        @isSending = true
        @group = new Hooful.Collections.Groups()
        @group.fetch(
          data: {mDate: $('#particeDate').val(), mUserid: userid, category: that.options.category, type: "getRecommend"}
          type: "POST"
          success: =>
            if @group.models[0].get('_id')
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
              #$('#groupReccomendModal').modal('hide')
              $('#modalResponse').click().remove()
            else
              event.stopPropagation();
              alert "오류가 발생했습니다. 다시 시도해 주세요."
            @isSending = false
        )
      ), 2000

  noDate: ->
    $(".date").removeClass("active")
    $("#particeDate").val ""


class Hooful.Views.HoofulsNotInGroup extends Backbone.View

  template: JST['hoofuls/not_in_group']
  tagName: 'div'

  events:
    'click .btn.partice': 'particeGroup'
    'click .btn.goback': 'goBack'

  initialize: ->
    @isSending = false

  render: (target)->
    $(@el).html(@template())
    this
  particeGroup: ->
    if typeof (userid) is "string" and userid isnt ""
      $("#groupModal").remove()
      gpartice = new Hooful.Views.HoofulsGroupPartice(gid: $('#groupTalk').attr("_id"),category: $('#groupTalk').attr("category"))
      $('body').append(gpartice.render('').el)
      $("#groupModal").modal()
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/g/"+$('#groupTalk').attr("_id"))
      return false
  goBack: ->
    history.back -1

class Hooful.Views.HoofulsGroupSearching extends Backbone.View

  template: JST['hoofuls/group_searching']
  tagName: 'div'

  initialize: ->

  render: (target)->
    $(@el).html(@template(userid:@options.userid,picture: @options.picture))
    this    
    