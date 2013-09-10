class Hooful.Views.HoofulsService extends Backbone.View

  initialize: ->
    @review = new Hooful.Collections.Tohoofuls()
    @review.fetch(
      data: {userid: $('.hManage').attr('mhost')}
      type: "GET"
      success: =>
        if @review.length > 0
          service_list = new Hooful.Views.HoofulsServiceList(@review)
          $('.hmsRight .dTable').append(service_list.render().el)
    )
    $(".hmsHeader .btn.grey").click @reviewWrite

  reviewWrite: ->
    if $('#mUserid').val() is ""
      alertMove("로그인 이후 이용 가능합니다.","/signin","/"+$('#mCode').val())
      return false
    else
      $("#service_write_modal").remove()
      review_write = new Hooful.Views.HoofulsServiceWrite()
      $('body').append(review_write.render().el)
      $("#service_write_modal").modal()

class Hooful.Views.HoofulsServiceCommon extends Backbone.View

  initialize: ->
    @review = new Hooful.Collections.Tohoofuls()
    @review.fetch(
      data: {userid: $('.hManage').attr('mhost')}
      type: "GET"
      success: =>
        if @review.length > 0
          service_list = new Hooful.Views.HoofulsServiceList(@review)
          $('.hmsRight .dTable').append(service_list.render().el)
    )
    $(".btnQuestion").click @reviewWrite

  reviewWrite: ->
    if $('#mUserid').val() is ""
      alertMove("로그인 이후 이용 가능합니다.","/signin","/"+$('#mCode').val())
      return false
    else
      $("#service_write_modal").remove()
      review_write = new Hooful.Views.HoofulsServiceWrite()
      $('body').append(review_write.render().el)
      $("#service_write_modal").modal()

class Hooful.Views.HoofulsServiceList extends Backbone.View

  template: JST['hoofuls/service_list']
  tagName: 'tbody'

  events:
    'click td.title': 'openReview'
    'click .hmsRight .summary': 'openReview'
    
  initialize: ->
    @isSending = false

  render:(size) ->
    $(@el).html(@template(services: @options))
    this

  openReview:(e) ->
    if @isSending is false
      @isSending = true
      @review = new Hooful.Collections.TohoofulsDetail({},{id: $(e.target).parent().attr("sid")})
      @review.fetch(
        type: "GET"
        success: =>
          $("#service_modal").remove()
          review_detail = new Hooful.Views.HoofulsServiceDetail(@review)
          $('body').append(review_detail.render().el)
          $("#service_modal").modal()
          @isSending = false
      )
    else
      alert "후기를 불러오는 중입니다."

class Hooful.Views.HoofulsServiceDetail extends Backbone.View

  template: JST['hoofuls/service_detail']
  tagName: 'div'
    
  initialize: ->
    
  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","service_modal").html(@template(review_detail: @options.models[0]))
    this

class Hooful.Views.HoofulsServiceWrite extends Backbone.View

  template: JST['hoofuls/service_write']
  tagName: 'div'

  events:
    'click .modal-footer .btn': 'sendReview'  

  initialize: ->


  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","service_write_modal").html(@template())
    this
  
  sendReview: ->
    if $('.hManage').attr('mhost') is ""
      alert "로그인이 필요합니다."
    else if $('#mTitle').val() is ""
      alert "문의하실 제목을 입력해 주세요."
    else if $('#mReview').val() is ""
      alert "문의하실 내용을 입력해 주세요."
    else
      @review = new Hooful.Collections.Tohoofuls()
      @review.fetch(
        data: {userid: $('.hManage').attr('mhost'), email: $('#email').val(), title: $('#mTitle').val(), article: $('#mReview').val(),type: 'manage'}
        type: "POST"
        success: =>
          if @review.models[0].get('_id') isnt ""
            alert "문의가 접수 되었습니다."
            $("#service_write_modal").modal('hide')
          else if @review.models[0].get('_id') is ""
            alert "오류가 발생했습니다. 문의 접수가 되지 않았습니다."
          else
            alert "작성된 내용이 부족합니다. 문의 접수가 되지 않았습니다."
          
      )