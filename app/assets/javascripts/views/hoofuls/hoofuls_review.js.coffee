
class Hooful.Views.HoofulsReview extends Backbone.View

  events:
    'click .btn_review_write': 'reviewWrite'

  initialize: ->
    @review = new Hooful.Collections.Reviews()
    @review.fetch(
      data: {mCode: $('#mCode').val(), mHost: $('#mHost').val()}
      type: "GET"
      success: =>
        if @review.length > 0
          review_list = new Hooful.Views.HoofulsReviewList(@review)
          $('.mReview dd div').html(review_list.render().el)
    )
    if typeof (userid) is "string" and userid isnt ""
      $('.mReview dt').append('<a class="btn_review_write">후기작성하기</a>')
      $(".btn_review_write").click @reviewWrite

  reviewWrite: ->
    if typeof (userid) is "string" and userid isnt ""
      $("#review_write_modal").remove()
      review_write = new Hooful.Views.HoofulsReviewWrite()
      $('body').append(review_write.render().el)
      $("#review_write_modal").modal()
      $(".redactor").redactor imageUpload: "/api/editorupload?userid=" + userid
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/"+$('#mCode').val())
      return false
        

class Hooful.Views.HoofulsReviewList extends Backbone.View

  template: JST['hoofuls/review']
  tagName: 'div'

  events:
    'click div.prev': 'loadPrev'
    'click div.next': 'loadNext'
    'click .review .title': 'openReview'
    'click .review .summary': 'openReview'
    
  initialize: ->
    @isSending = false

  render:(size) ->
    $(@el).html(@template(reviews: @options))
    this

  loadPrev: ->
    if @isSending is false
      @isSending = true
      @review = new Hooful.Collections.Reviews()
      @review.fetch(
        data: {mCode: $('#mCode').val(), mHost: $('#mHost').val(), firstReview: $('.review:first').attr("rid")}
        type: "GET"
        success: =>
          review_list = new Hooful.Views.HoofulsReviewList(@review)
          $('.mReview dd').html(review_list.render().el)
          $('.hcReviewList').html(review_list.render().el)
          @isSending = false
      )
    else
      alert "후기를 불러오는 중입니다."
  loadNext: ->
    if @isSending is false
      @isSending = true
      @review = new Hooful.Collections.Reviews()
      @review.fetch(
        data: {mCode: $('#mCode').val(), mHost: $('#mHost').val(),lastReview: $('.review:last').attr("rid"), category:$('.hcReviewList ').attr('category')}
        type: "GET"
        success: =>
          $(".review_list .next").remove()
          $(".hcReviewList .next").remove()
          review_list = new Hooful.Views.HoofulsReviewList(@review)
          $('.mReview dd').append(review_list.render().el)
          $('.hcReviewList').append(review_list.render().el)
          @isSending = false
      )
    else
      alert "후기를 불러오는 중입니다."
  openReview:(e) ->
    if @isSending is false
      @isSending = true
      @review = new Hooful.Collections.ReviewDetail({},{id: $(e.target).parent(".review").attr("rcode")})
      @review.fetch(
        type: "GET"
        success: =>
          $("#review_modal").remove()
          review_detail = new Hooful.Views.HoofulsReviewDetail(@review)
          $('body').append(review_detail.render().el)
          $("#review_modal").modal()

          review_wrap = new Hooful.Views.HoofulsReviewCmtWrap(rCode: $(e.target).parent(".review").attr("rcode"))
          $('#review_modal .modal-footer').html(review_wrap.render().el)
          @isSending = false
      )
    else
      alert "후기를 불러오는 중입니다."

class Hooful.Views.HoofulsReviewDetail extends Backbone.View

  template: JST['hoofuls/review_detail']
  tagName: 'div'
    
  initialize: ->
    
  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","review_modal").html(@template(review_detail: @options.models[0]))
    this

class Hooful.Views.HoofulsReviewCmtWrap extends Backbone.View

  template: JST['hoofuls/review_comment_wrap']
  tagName: 'div'

  events:
    'click .comment_write .btn.grey': 'reviewWrite'

  initialize: ->
    @isSending = false
    _.bindAll(this,'reviewWrite')
    @review_cmt = new Hooful.Collections.ReviewCmts()
    @review_cmt.fetch(
      data: {rCode: @options.rCode , rUserid: userid}
      type: "GET"
      success: =>
        review_cmt = new Hooful.Views.HoofulsReviewCmt(@review_cmt)
        $('#review_modal .modal-footer .comment_list').html(review_cmt.render().el)
    )

  render:(size) ->
    $(@el).html(@template(userid: userid, picture:$("#hUserNav img").attr("src"), name: $("#hUserNav .name").text(), rCode: @options.rCode))
    this

  reviewWrite: ->
    if $('#mComment').val() is ""
      alert "댓글 내용을 입력해 주세요"
    else
      if @isSending is false
        @isSending = true
        @review_cmt = new Hooful.Collections.ReviewCmts()
        @review_cmt.fetch(
          data: {rCode: @options.rCode , rUserid: userid, rMsg: $('#mComment').val(),lastTalk: $('.comment_list .comment_each:last').attr("rid")}
          type: "POST"
          success: =>
            review_cmt = new Hooful.Views.HoofulsReviewCmt(@review_cmt)
            $('#review_modal .modal-footer .comment_list').append(review_cmt.render().el)
            $('#mComment').val ""
            @isSending = false
        )
      else
        alert "댓글을 전송중입니다."

class Hooful.Views.HoofulsReviewCmt extends Backbone.View

  template: JST['hoofuls/review_comment']
  tagName: 'div'
  events:
    'click .more': 'loadPrev'

  initialize: ->
    @isSending = false

  render:(size) ->
    $(@el).html(@template(cmts: @options))
    this

  loadPrev: ->
    if @isSending is false
      @isSending = true
      @review_cmt = new Hooful.Collections.ReviewCmts()
      @review_cmt.fetch(
        data: {rCode: $('#rCode').val() , mUserid: userid , firstTalk: $('.comment_list .comment_each:first').attr("rid")}
        type: "GET"
        success: =>
          $('.comment_list .more').remove()
          review_cmt = new Hooful.Views.HoofulsReviewCmt(@review_cmt)
          $('#review_modal .modal-footer .comment_list').prepend(review_cmt.render().el)
          @isSending = false
      )
    else
      alert "댓글을 불러오는 중입니다."

class Hooful.Views.HoofulsReviewWrite extends Backbone.View

  template: JST['hoofuls/review_write']
  tagName: 'div'

  events:
    'click .modal-footer .btn_next.complete': 'sendReview'  

  initialize: ->
    @remeet = new Hooful.Collections.ReviewMeets()
    @remeet.fetch(
      data: {mHost: userid, category:@options.category}
      success: =>
        if @remeet.length > 0
          reOpen = new Hooful.Views.HoofulsReopen(@remeet)
          $('.activity .dropdown-menu').html(reOpen.render().el)
        else
           $('.activity .dropdown-menu').remove()
           $('.activity a').text("참가한 활동이 없습니다.")
    )  
  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","review_write_modal").html(@template())
    this
  
  sendReview: ->
    if $('#mWriter').val() is ""
      alert "로그인이 필요합니다."
    else if $('.activity .dropdown-menu').length is 0
      alert "참가한 활동이 없습니다."
    else if $('#mReviewCode').val() is ""
      alert "참가했던 활동을 선택해 주세요."
    else if $('#mTitle').val() is ""
      alert "활동후기 제목을 입력해 주세요."
    else if $('#mReview').val() is ""
      alert "활동후기 내용을 입력해 주세요."
    else
      @review = new Hooful.Collections.Reviews()
      @review.fetch(
        data: {mWriter: $('#mWriter').val(), mCode: $('#mReviewCode').val(), mTitle: $('#mTitle').val(), mReview: $('#mReview').val()}
        type: "POST"
        success: =>
          if @review.models[0].get('result') is "true"
            alert "활동후기가 작성되었습니다."
            $('#modalResponse').click()
            @review = new Hooful.Collections.Reviews()
            @review.fetch(
              data: {mCode: $('#mCode').val(), mHost: $('#mHost').val(), category:$('.hcReviewList ').attr('category')}
              type: "GET"
              success: =>
                review_list = new Hooful.Views.HoofulsReviewList(@review)
                $('.mReview dd div').html(review_list.render().el)
                $('.hcReviewList').html(review_list.render().el)
            )
          else if @review.models[0].get('result') is "false"
            alert "오류가 발생했습니다. 후기가 작성되지 않았습니다."
          else
            alert "작성된 내용이 부족합니다. 후기가 작성되지 않았습니다."
          
      )


class Hooful.Views.HoofulsCommunityReview extends Backbone.View

  initialize: ->
    _.bindAll(this,'reviewWrite')
    @category = @options.category
    @review = new Hooful.Collections.Reviews()
    @review.fetch(
      data: {category:@options.category}
      type: "GET"
      success: =>
        if @review.length > 0
          review_list = new Hooful.Views.HoofulsReviewList(@review)
          $('.hcReviewList').html(review_list.render().el)
    )
    $('.hcReviewList').attr("category",@options.category)
    $("#hcReviewWrite").click @reviewWrite

  reviewWrite: ->
    if typeof (userid) is "string" and userid isnt ""
      $("#review_write_modal").remove()
      review_write = new Hooful.Views.HoofulsReviewWrite(category: @options.category)
      $('body').append(review_write.render().el)
      $("#review_write_modal").modal()
      $(".redactor").redactor imageUpload: "/api/editorupload?userid=" + userid
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/c/"+@options.category)