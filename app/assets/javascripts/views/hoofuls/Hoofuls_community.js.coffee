class Hooful.Views.HoofulsCommunityTalk extends Backbone.View

  template: JST['hoofuls/community_talk']

  initialize: ->
    this.count = 1
    this.limit = 4
    this.isLoading = false
    _.bindAll(this, 'getContents', 'sendTalk', 'changeMore')
    $('.ctalkbtn').click(this.sendTalk)
    $('#thMore').click(this.changeMore)
    @getContents()
    @isSending = false

  render: ->
    $(@el).html(@template())
    this
    
  sendTalk: ->
    if $('#ctalkInput').val() is ""
      alert "메세지를 입력해 주세요."
      $('#ctalkInput').focus()
    else
      if @isSending is false
        @isSending = true
        @group = new Hooful.Collections.CommunityTalk()
        @group.fetch(
          data: {mCode: $('#mCode').val() , message: $('#ctalkInput').val() , mUserid: $('#cHost').val(), type: "sendTalk"}
          type: "POST"
          success: =>
            @getContents()
            $('#ctalkInput').val ""
            @isSending = false
        )
      else
        alert "메세지를 전송중입니다."
    
  getContents: ->
    this.isLoading = true
    this.count = 1
    $("#thMore").show()
    @grouptalks = new Hooful.Collections.CommunityTalk()
    @grouptalks.fetch(
      data: {page: this.count, mCode: $('#mCode').val()}
      type: "GET"
      success: =>
        group_msg = new Hooful.Views.HoofulsCommunityMessage(@grouptalks)
        $('.hcTalk').removeAttr("style")
        $(".hcTalkList").scrollTop $(".hcTalkList").height()
        $("#thMore").hide() if @grouptalks.length < this.limit
        $.gVal = tHeight: 0
        $('.hcTalkList > div').each ->
          $.gVal.tHeight += $(this).height()
        $('.hcTalk').height($.gVal.tHeight+250)
        $('.hcMeet').height($('.hcTalk').height()) if $('.hcMeet').height() < $('.hcTalk').height()
    )
    
  moreContents: ->
    this.isLoading = true
    @grouptalks = new Hooful.Collections.CommunityTalk()
    @grouptalks.fetch(
      data: {page: this.count, mCode: $('#mCode').val()}
      type: "GET"
      success: =>
        group_msg = new Hooful.Views.HoofulsCommunityMessage2(@grouptalks)
        $('.hcTalk').removeAttr("style")
        $(".hcTalkList").scrollTop $(".hcTalkList").height()
        $("#thMore").hide() if @grouptalks.length < this.limit
        $.gVal = tHeight: 0
        $('.hcTalkList > div').each ->
          $.gVal.tHeight += $(this).height()
        $('.hcTalk').height($.gVal.tHeight+600)
        $('.hcMeet').height($('.hcTalk').height()) if $('.hcMeet').height() < $('.hcTalk').height()
    )

  changeMore: ->
    this.count += 1
    @moreContents()

class Hooful.Views.HoofulsCommunityTicket extends Backbone.View

  template: JST['hoofuls/community_ticket']
  tagName: 'span'

  events:
    'click tr.tlink' : 'setTlink'

  initialize: ->
    this.sort = 'asc'
    this.mcode = $('#mCode').val()
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'setOrder', 'setTlink')
    $('i.hManage').click(this.setOrder)
    $('tr.tlink').click(this.setOrder)
    @loadResult()

  render: ->
    $(@el).html(@template(tickets: @tickets, S3ADDR: @S3ADDR))
    this

  loadResult: ->
    @tickets = new Hooful.Collections.CommunityTicket({},{sort: this.sort, mCategory: this.mcode})
    @tickets.fetch(success: =>
      @render()
    )

  setOrder: (e) ->    
    if $(e.currentTarget).hasClass("set") and $(e.currentTarget).hasClass("iArrowdown")
      this.sort = "asc"
      $(e.currentTarget).removeClass("iArrowdown").addClass("iArrowup")
    else if $(e.currentTarget).hasClass("set") and $(e.currentTarget).hasClass("iArrowup")   
      this.sort = "desc"
      $(e.currentTarget).removeClass("iArrowup").addClass("iArrowdown") 
    else
      this.sort = "asc"
    @loadResult()

  setTlink: (e) ->
    window.open('/'+$(e.currentTarget).attr("code"),'hooful')


class Hooful.Views.HoofulsCommunityMessage extends Backbone.View

  template: JST['hoofuls/community_message']

  initialize: ->
    @loadResult()

  render: ->
    this

  loadResult: ->
    $('.hcTalkList').html(@template({talks: @options.models, date:@formatDate(new Date())}))
      
  formatDate : (date) ->
    timeStamp = [date.getFullYear(), (date.getMonth() + 1), date.getDate()].join(" ")
    RE_findSingleDigits = /\b(\d)\b/g

    timeStamp = timeStamp.replace( RE_findSingleDigits, "0$1" )
    timeStamp.replace /\s/g, "-"

class Hooful.Views.HoofulsCommunityMessage2 extends Backbone.View

  template: JST['hoofuls/community_message']

  initialize: ->
    @loadResult()

  render: ->
    this

  loadResult: ->
    $('.hcTalkList').append(@template({talks: @options.models, date:@formatDate(new Date())}))
      
  formatDate : (date) ->
    timeStamp = [date.getFullYear(), (date.getMonth() + 1), date.getDate()].join(" ")
    RE_findSingleDigits = /\b(\d)\b/g

    timeStamp = timeStamp.replace( RE_findSingleDigits, "0$1" )
    timeStamp.replace /\s/g, "-"


class Hooful.Views.HoofulsCommunityDocument extends Backbone.View

  template: JST['hoofuls/community_document']
  tagName: 'ul'

  events:
    'click .doc' : 'viewDocument'

  initialize: ->

  render: ->
    @cdoc = new Hooful.Collections.CommunityDoc()
    @cdoc.fetch(
      data: {mCode: $('#mCode').val()}
      type: "GET"
      success: =>
        if @cdoc.length > 0
          $(@el).html(@template(cdoc : @cdoc))
    )
    this

  viewDocument: (e) ->
    @wdetail = new Hooful.Collections.CommunityDocDetail({},{id: $(e.currentTarget).attr('code')})
    @wdetail.fetch(
      type: "GET"
      success: =>
        if @wdetail.models.length > 0
          $("#community_modal").remove()
          review_detail = new Hooful.Views.HoofulsCommunityDocumentDetail(@wdetail)
          $('body').append(review_detail.render().el)
          $("#community_modal").modal()
    )

class Hooful.Views.HoofulsCommunityDocumentDetail extends Backbone.View

  template: JST['hoofuls/community_detail']
  tagName: 'div'
    
  initialize: (options) ->
    
  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","community_modal").html(@template(detail:@options))
    this

class Hooful.Views.HoofulsCommunityDocumentWrite extends Backbone.View

  template: JST['hoofuls/community_write']
  tagName: 'div'

  events:
    'click .modal-footer .btn_next.complete': 'sendReview'  
    'change #uploadFile': 'uploadModal'
    'click #uploadResponse': 'uploadResponse'

  initialize: ->

  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","community_write_modal").html(@template(options: @options))
    this
  
  uploadModal: (event) ->
    $("#uploadForm").submit()
    $("#uploadForm .preview").after("<img src='http://d3o755op057jl1.cloudfront.net/hooful/loading.gif' class='loading'/>").hide()
    $("#uploadComplete").attr "disabled", true

  uploadResponse: (event) ->
    unless $("#uploadFile").val is ""
      $("#uploadForm .preview").attr("src", "http://d3o755op057jl1.cloudfront.net/" + $("#uploadForm #uploadPath").val() + "/" + $("#uploadvURL").val()).show()
      $("#uploadForm .loading").remove()
      $("#uploadComplete").attr "disabled", false
    else
      $("#uploadForm .preview").attr("src", "http://d3o755op057jl1.cloudfront.net/" + $("#uploadForm #uploadPath").val() + "/noimage.png").show()
      $("#uploadForm .loading").remove()
      $("#uploadURL").val "noimage.png"
      $("#uploadvURL").val "noimage.png"
      alert "파일 업로드에 실패했습니다."
      $("#uploadComplete").attr "disabled", false

  sendReview: (event)->
    if $('#mTitle').val() is ""
      alert "활동설명 제목을 입력해 주세요."
    else if $('#mContents').val() is ""
      alert "활동설명 내용을 입력해 주세요."
    else
      @cdoc = new Hooful.Collections.CommunityDoc()
      @cdoc.fetch(
        data: {mCategory: $('#mCode').val(), mUserid:$('#mWriter').val(), mTitle: $('#mTitle').val(), mContents: $('#mContents').val(), mPicture: $('#uploadvURL').val()}
        type: "POST"
        success: =>
          if @cdoc.models[0].get('result') is "true"
            alert "활동설명이 작성되었습니다."
            $('#modalResponse').click()
          else if @cdoc.models[0].get('result') is "false"
            alert "오류가 발생했습니다. 활동설명이 작성되지 않았습니다."
          else
            alert "작성된 내용이 부족합니다. 활동설명이 작성되지 않았습니다."
      )