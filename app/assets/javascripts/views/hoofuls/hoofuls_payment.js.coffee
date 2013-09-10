class Hooful.Views.HoofulsPayment extends Backbone.View

  initialize: ->
    @isSending = false
    _.bindAll(this, 'checkBox', 'paySubmit', 'callbacksuccess','payConfirm')
    $(".mPayselect .checkbox").click @checkBox
    $("#callback").click @callbacksuccess
    $("#openPaygate").click @paySubmit
    $("#payConfirm").click @payConfirm
    @name = navigator.appName
    ua = navigator.userAgent
    @osinfo = ""
    unless ua.indexOf("NT 6.0") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("NT 5.2") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("NT 5.1") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("NT 5.0") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("NT") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("9x 4.90") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("98") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("95") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("Win16") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("Windows") is -1
      @osinfo = "Windows"
    else unless ua.indexOf("Linux") is -1
      @osinfo = "Linux"
    else unless ua.indexOf("Macintosh") is -1
      @osinfo = "Macintosh"
    else
      @osinfo = ""

  render: ->

  paySubmit: ->
    set = false
    if $("#phone").val() is ""
      @showMessage("휴대전화를 입력해 주세요.")
    else if $("#dob").val() is ""
      @showMessage("생년월일을 입력해 주세요.")
    else if $("#job").val() is ""
      @showMessage("직업을 입력해 주세요.")
    else if $("#local").val() is ""
      @showMessage("거주지를 입력해 주세요.")
    else
      @startPayment()
      set = true
    return set

  payConfirm: ->
    if $("#phone").val() is ""
      @showMessage("휴대전화를 입력해 주세요.")
    else if $("#dob").val() is ""
      @showMessage("생년월일을 입력해 주세요.")
    else if $("#job").val() is ""
      @showMessage("직업을 입력해 주세요.")
    else if $("#local").val() is ""
      @showMessage("거주지를 입력해 주세요.")
    else
      if @isSending is false
        @isSending = true
        @partice = new Hooful.Collections.Payment()
        @partice.fetch(
          data: {
            phone: $('#phone').val(),
            dob: $('#dob').val(),
            job: $('#job').val(),
            local: $('#local').val(),
            ticketInfo: $('#ticketInfo').val(),
            mPayUse: $('#mPayUse').val(),
            mCode: $('#mCode').val(),
            mUserid: $('#mUserid').val(), 
            mDate: $('#mDate').val(), 
            mTimeS: $('#mTimeS').val(), 
            mParticeCheck: $('#mParticeCheck').val(), 
            type: "free"
          }
          type: "POST"
          success: =>
            alert "참여가 확정되었습니다."  
            location.href = "/"+$('#mCode').val()
        )
      else
        alert "참여확정이 진행중입니다."
    false
    
  showMessage: (message) ->
    alertView(message)
    
  startPayment: ->
    if @name isnt "Microsoft Internet Explorer" and   @osinfo is "Windows" and $("#payMethodType").val() is "4"
      alert "윈도우 환경에서 계좌이체를 하시려면\nInternet Explorer로 진행해주세요." 
    else
      alert "윈도우 환경에서 KB, BC 카드로 결제를 하시려면\nInternet Explorer로 진행해주세요." if @name isnt "Microsoft Internet Explorer" and   @osinfo is "Windows" and $("#payMethodType").val() is "card"
      $("#payBackground").modal().on "hide", ->
        $('#hPayfrm').attr("action","/payment").attr("method","post").submit()
      doTransaction document.forms["PGIOForm"]

  callbacksuccess : ->
    replycode = getPGIOElement("replycode")
    replyMsg = getPGIOElement("replyMsg")
    if replycode is "0000"
      if @isSending is false
        @isSending = true
        @partice = new Hooful.Collections.Payment()
        @partice.fetch(
          data: {
            phone: $('#phone').val(),
            dob: $('#dob').val(),
            job: $('#job').val(),
            local: $('#local').val(),
            ticketInfo: $('#ticketInfo').val(),
            mPayUse: $('#mPayUse').val(),
            mCode: $('#mCode').val(),
            mUserid: $('#mUserid').val(), 
            mDate: $('#mDate').val(), 
            mTimeS: $('#mTimeS').val(), 
            mParticeCheck: $('#mParticeCheck').val(), 
            mid: getPGIOElement('mid'),
            paymethod: getPGIOElement('paymethod'),
            cardtype: getPGIOElement('cardtype'),
            cardauthcode: getPGIOElement('cardauthcode'),
            goodname: getPGIOElement('goodname'),
            unitprice: getPGIOElement('unitprice'),
            goodcurrency: getPGIOElement('goodcurrency'),
            currency_org: getPGIOElement('currency_org'),
            price_org: getPGIOElement('price_org'),
            receipttoname: getPGIOElement('receipttoname'),
            receipttoemail: getPGIOElement('receipttoemail'),
            receipttotel: getPGIOElement('receipttotel'),
            replyMsg: getPGIOElement('replyMsg'),
            resultcode: getPGIOElement('resultcode'),
            tid: getPGIOElement('tid'),
            type: "pay"
          }
          type: "POST"
          success: =>
            alert "결제가 완료되었습니다." 
            $('#hPayfrm').attr("action","/paysuccess").attr("method","post").submit()
            #location.href = "/payment/"+@partice._id
        )
      else
        alert "결제가 진행중입니다."
      
    else
      result = ""
      if @name isnt "Microsoft Internet Explorer" and @osinfo is "Windows" and $(".payCard").hasClass("active")
        result = "윈도우 환경에서 KB, BC 카드로 결제를 하시려면\nInternet Explorer로 진행해주세요."
      else
        result = "결제가 처리되지 않아서 상세페이지로 이동합니다.\n" + replyMsg + "( 에러코드: " + replycode + ")"
      alert result

  checkBox: (event) ->
    status = $(event.target).hasClass "active"
    target = $(event.target).attr "target"
    if status
        $(event.target).removeClass("active").children('input').val 0 unless target
    else
       if target
          chkval = $(event.target).attr "value"
          $('[target="'+target+'"]').removeClass("active")
          $(event.target).addClass("active")
          $('#'+target).val chkval
       else
           $(event.target).addClass("active").children('input').val 1
