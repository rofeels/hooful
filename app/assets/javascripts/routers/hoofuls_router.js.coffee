class Hooful.Routers.Hoofuls extends Backbone.Router
  routes:
    'home': 'index'
    'test': 'test'
    'intro': 'intro'
    'search/(:keyword)' : 'meet_search'
    'meet/create': 'meet_create'
    'meet/subscription': 'meet_subscription'
    'meet/manage/withdraw': 'meet_withdraw'
    'meet/:mcode': 'meet_manage'
    'api/upload': 'api_upload'
    'user/reset_password' : 'user_reset'
    'user/change_password' : 'user_change'
    'user/edit' : 'user_edit'
    'user/edit/certification' : 'user_edit_certification'
    'user/edit/password' : 'user_edit_password'
    'user/edit/sns' : 'user_edit_sns'
    'user/edit/category' : 'user_edit_category'
    'user/ticket' : ''
    'user/ticket/old' : ''
    'user/ticket/reserved' : ''
    'user(/:id)': 'user_index'
    'signin' : 'user_signin'
    'support' : ''
    'support/notice(/:id)' : 'support_notice'
    'support/hooful' : 'support_hooful'
    'support/faq' : 'support_faq'
    'notification' : 'notification_list'
    'welcome' : ''
    'c/:mCategory' : 'meet_category'
    'r' : 'review_index'
    'rwrite' : 'review_write'
    'r/:rid' : 'review_detail'
    'h' : 'hope_index'
    'hwrite' : 'hope_write'
    'h/:rid' : 'hope_detail'
    'g/:gid' : 'group_show'
    'signup(:hash)' : 'user_signup'
    'signup/step1' : 'user_signup'
    'signup/step2':'choice_category'
    'signup/step3':'user_signup_certification'
    'signup/complete':'user_signup_complete'
    'payment': 'payment'
    ':mcode/edit': 'meet_edit'
    ':mcode/reservation': 'meet_reservation'
    ':mcode/reservation/:tcode': 'meet_reservation'
    ':mcode': 'meet_view'

  initialize: ->
    search = new Hooful.Views.HoofulsSearchBar()
    #$('header').append(search.render().el)
    #if typeof userid is "string" and userid isnt ""
      #notice = new Hooful.Views.HoofulsNotification()
      #$('#hNoticeWrap #hNoticeList').html(notice.render().el)
    this.authStatus = "1"
      
  index: ->
    meet = new Hooful.Views.HoofulsHoofulmeet({keyword:''})
    $('#hMoim').html(meet.render().el)

    $('.step1 > .btnTnext').click (e) ->
      $('.bgTutorial').css({'backgroundColor':'transparent'})
      $('html body').animate({scrollTop:198}, 500)
      $('.bgTutorial > .step1').fadeOut()
      $('.bgTutorial > .step2').fadeIn()

    $('.step2 > .tbox > .btnTnext').click (e) ->
      $('html body').animate({scrollTop:1103}, 500)
      $('.bgTutorial > .step2').fadeOut()
      $('.bgTutorial > .step3').fadeIn()

    $('.step3 > .tbox > .btnTlets').click (e) ->
      $('.bgTutorial').fadeOut()
      $('html body').animate({scrollTop:0}, 300)

  intro: ->

  meet_search: (keyword) ->
    $("#hSearchIcon").css "background-position", "-30px 0"
    $("#mSearch").val(keyword)
    $("#hSearchIcon").addClass("set")
    $("#hSearchIcon").css "background-position", "-30px 0"
    $('#hSearchBar').slideDown('slow')
    $('#hContainer').animate
      marginTop: "90px"
    , 600
    $("#hSearchIcon").css "background-position", "-30px 0"
    #meet = new Hooful.Views.HoofulsHoofulmeet({keyword:keyword})
    #$('#hMoim').html(meet.render().el)
    person = new Hooful.Views.HoofulsHoofulperson({keyword:keyword})
    $('#hPerson').html(person.render().el)

  meet_create: ->
    $('[data-toggle="tooltip"]').tooltip()
    upfile = new Hooful.Views.HoofulsUpload(type: "meetpic", userid: $("#mHost").val())
    $('body').append(upfile.render().el)
    
    category = new Hooful.Views.HoofulsCategory()
    $('.category.btn-group .dropdown-menu').append(category.render().el)
    
    calendar = new Hooful.Views.HoofulsCalendar()
    $('.date .btn').append(calendar.render($('.date .btn').attr("target"), '').el)
    
    map = new Hooful.Views.HoofulsMap()
    $('.place .btn').append(map.render($('.place .btn').attr("target"), '').el)

    ticket_wrap = new Hooful.Views.HoofulsTicketWrap()
    $('div.tickets').append(ticket_wrap.render().el)

    ticketeach = new Hooful.Views.HoofulsTicket()
    $('#addTicket').click()
    
    $(".addition .sns .btn-auth").click ->
      target = (if ($(this).children("i").attr("class") is "twitter") then "tuid" else "fuid")
      if $(this).hasClass("disabled") is true
        $(this).removeClass "disabled"
        $("#" + target).val 1
      else
        $(this).addClass "disabled"
        $("#" + target).val 0

    $(".pholder").click ->
      target = $(this).attr("target")
      $(this).hide()
      $('#'+target).addClass("set")
      $('#'+target).focus()

    $(".pinput").click ->
      $('.pholder[target="'+$(this).attr("id")+'"]').hide()
      $(this).addClass("set")
      $(this).focus()

    $(".pinput").blur ->
      if $(this).val()
        $(this).addClass("set")
      else
        $(this).removeClass("set")
        $('.pholder[target="'+$(this).attr("id")+'"]').show()

    $(".pinput").keyup (e) ->
      if $(this).val()
        $(this).addClass("set")
      else
        $(this).removeClass("set")
	
    $(".checkbox").click ->
      status = $(this).hasClass "active"
      target = $(this).attr "target"
      if status
          $(this).removeClass("active").children('input').val 0 unless target
      else
         if target
            chkval = $(this).attr "value"
            $('[target="'+target+'"]').removeClass("active")
            $(this).addClass("active")
            $('#'+target).val chkval
         else
             $(this).addClass("active").children('input').val 1
    validate = new Hooful.Views.HoofulsMeetValidate()

  meet_subscription: ->
    
  api_upload: ->
    $(window).load ->
      parent.$("#uploadURL").val $("#uploadURL").val()
      parent.$("#uploadvURL").val $("#uploadvURL").val()
      parent.$("#uploadResponse").click()

  user_index: ->
    #meet = new Hooful.Views.HoofulsUsermeet()
    #$('#hMoim').html(meet.render().el)
    if (typeof userid is "string" and userid isnt "") and ($('#hUserinfo').attr('userid') is userid)
      $('#hUserMore #comment').click ->
        $('#hUserMore #comment span').hide()
        $('#hUserMore #comment textarea').show()
        $('#hUserMore #comment').removeClass "none"
        $('#hUserMore #comment').addClass "focus"
      $('#hUserMore #comment').focusout ->
        $('#hUserMore #comment').removeClass "focus"
        $('#hUserMore #comment').addClass "none"
        @comment_edit = new Hooful.Collections.CommentEdit()
        @comment_edit.fetch(
          data: {comment:$("#hUserMore #comment textarea").val(), userid:userid}
          type: "POST"
          success: =>
            $('#hUserMore #comment span').html(@comment_edit.models[0].get('comment')+'<i class="icon-pencil"></i>')
            $('#hUserMore #comment span').show()
            $('#hUserMore #comment textarea').hide()
        )
    guestbook_wrap = new Hooful.Views.HoofulsGuestbookWrap()
    $('#uGuestbook dd').html(guestbook_wrap.render().el)
    user_group = new Hooful.Views.HoofulsUserGroup(mUserid: $('#hUserinfo').attr('userid'))
    $('#uGroup dd.group .box').html(user_group.render().el)


  user_edit: ->
    upfile = new Hooful.Views.HoofulsUpload(
      type: "userpic"
      userid: $("#userid").val()
    )
    $('body').append(upfile.render().el)
    $('li.job').click (e) ->
      $('#job').val $(e.currentTarget).text()
      $('#cUseredit .dropdown-toggle').html($(event.currentTarget).text()+"<span class=\"caret\"></span>")
    $.gVal = authStatus: "1"
    $('#btnAuthsend').click ->
      if $.gVal.authStatus is "1"
        @authsms = new Hooful.Collections.smsauthcode()
        @authsms.fetch(
          data: {phone:$('#phone').val(), userid:$('#userid').val()}
          type: "GET"
          success: =>
            if @authsms.models[0].get('result') is "exist"
              alert "다른 계정에 이미 인증된 번호입니다."
            else if @authsms.models[0].get('result') is "success"
              $('#authresult').val("")
              $('#authresultn').val("")
              alert "인증번호가 입력하신 번호로 전송되었습니다.\n인증번호를 확인해 주세요."
              $.gVal.authStatus = "0"
              $('#btnAuthsend').text("인증번호 재전송")
              $('#btnAuthsend').attr("disabled", "disabled")
              $('#phone').attr("disabled","disabled")
              $('.authcode').show()
              alert "authcode"
              $('#btnAuthsend').removeAttr("disabled")
              $('#authcode').removeAttr("disabled").val('')
              $('#authcode').val("")
              $('.authmsg').hide()
              window.setTimeout (->
                $.gVal.authStatus = "1"
                $("#phone").removeAttr "disabled"
              ), 60000
            else
              alert "다시 시도해 주시기 바랍니다."
        )
      else
        alert "1분후 재전송이 가능합니다."
    $('#btnAuthcheck').click ->
      $('#authresult').val("")
      $('#authresultn').val("")
      unless $("#authcode").val()
        alert "인증번호를 확인해 주세요."
      else
        @authsms = new Hooful.Collections.smsauthcheck()
        @authsms.fetch(
          data: {phone:$('#phone').val(), userid:$('#userid').val(), authcode:$('#authcode').val()}
          type: "GET"
          success: =>
            if @authsms.models[0].get('result') is "success"
              alert "핸드폰 인증이 완료 되었습니다."
              $('#authresult').val("success")
              $('#authresultn').val($('#phone').val())
              $('#btnAuthcheck').text("인증 완료")
              $('#authcode').attr("disabled","disabled")
              $('.authmsg').text($('#phone').val()+' 번호로 인증되었습니다.')
              $('.authmsg').show()
              $('.authcode').hide()
            else
              alert "인증번호가 일치하지 않거나 유효시간이 경과하였습니다."
        )
    $("#userpicMenu span").click ->
      $('.picture[path="userpic"] img').attr('src',$(this).attr('addr'))
      $('#userpic').val($(this).attr('for'))
      $('#userpicCopy').val($(this).attr('for'))

    $(".checkbox").click ->
      status = $(this).hasClass "active"
      target = $(this).attr "target"
      if status
          $(this).removeClass("active").children('input').val 0 unless target
      else
         if target
            chkval = $(this).attr "value"
            $('[target="'+target+'"]').removeClass("active")
            $(this).addClass("active")
            $('#'+target).val chkval
         else
             $(this).addClass("active").children('input').val 1

  user_edit_certification: ->
    upfile = new Hooful.Views.HoofulsUpload(
      type: "certificatioin"
      userid: $("#userid").val()
    )
    $('body').append(upfile.render().el)
    $('li.job').click (e) ->
      $('#job').val $(e.currentTarget).text()
      $('#cUsercert .dropdown-toggle').html($(e.currentTarget).text()+"<span class=\"caret\"></span>")
    $("#certSubmit").click ->
      unless $("#certpic").val()
        alert "증명할 사진을 첨부해 주세요." 
        false
        return
      unless $("#job").val()
        alert "직업분류를 선택해 주세요." 
        false
        return
      unless $("#members").val()
        alert "현재 소속을 입력해 주세요." 
        $("#members").focus()
        false
        return
      $("#hUserCert").submit()

  user_edit_password: ->
    $("#btnSave").click ->
      unless $("#old_password").val()
        alert "현재 비밀번호를 입력해 주세요." 
        $("#old_password").focus()
        false
        return
      unless $("#password").val()
        alert "비밀번호를 입력해 주세요." 
        $("#password").focus()
        false
        return
      unless $("#re_password").val()
        alert "비밀번호를 확인해 주세요." 
        $("#re_password").focus()
        false
        return
      unless $("#password").val() is $("#re_password").val()
        alert "비밀번호가 일치하지 않습니다." 
        $("#re_password").focus()
        false
        return
      $("#hUserPassword").submit()

  user_edit_sns: ->
    

  user_edit_category: ->
    $("#hInterests li.interest, #hInterests dl.interest").click (e) ->
      if $(this).hasClass("set")
        $(this).removeClass("set")
      else
        $(this).addClass("set")
    $.gVal = setCategory: "{"
    $(".btnSave").click ->
      $("#hInterests li.interest, #hInterests dl.interest").each (e) ->
        if $(this).hasClass("set")
          $.gVal.setCategory += '"'+$(this).attr("category")+'":"1",'
        else
          $.gVal.setCategory += '"'+$(this).attr("category")+'":"0",'
      $.gVal.setCategory = $.gVal.setCategory.substring(0,$.gVal.setCategory.length-1) + "}"
      @setCategory = new Hooful.Collections.SetCategory()
      @setCategory.fetch(
        data: {userid:$("#userid").val(), category:$.gVal.setCategory}
        type: "GET"
        success: =>
          if @setCategory.models[0].get('result') is "success"
            $('#update_txt').val('관심사가 변경되었습니다.')
            $('#hUserEdit').submit();
          else
            $('#update_txt').val('관심사가 저장되지 않았습니다. 다시 시도해 주세요.')
            $('#hUserEdit').submit();
      )
    false

  meet_view: (mcode) ->
    if (mcode is "#_=_") or (mcode is "_=_")
      meet = new Hooful.Views.HoofulsHoofulmeet()
      $('#hMoim').html(meet.render().el)
    else
      #review = new Hooful.Views.HoofulsReview()
      ticket_check = new Hooful.Views.HoofulsTicketCheck()

      hootalkwrap = new Hooful.Views.HoofulsHooTalkWrap()
      $('.Hootalk dd').html(hootalkwrap.render().el)
      #participantswrap = new Hooful.Views.HoofulsHooParticipantsWrap()
      #$('.mParticipants dd').html(participantswrap.render().el)
      quick = $(".mQuick")
      quick_top =parseInt($(".mQuick").css('top'))
      $(window).scroll -> 
          quick.stop()
          quick.animate
            top: $(document).scrollTop() + quick_top+ "px"
          , 1000
    
    if typeof (userid) is "string" and userid isnt ""
      @group = new Hooful.Collections.MeetGroup(mcode)
      @group.fetch(
        data: {mcode: mcode, userid:userid}
        type: "GET"
        success: =>
          result = @group.models[0]
          if result.get("result") is true
            group_talk = new Hooful.Views.HoofulsMeetGroupTalk(mcode:mcode)
            $('.mGroup dd').html(group_talk.render().el)
      )	  

  meet_edit: (mcode) ->
    $('[data-toggle="tooltip"]').tooltip()
    upfile = new Hooful.Views.HoofulsUpload(type: "meetpic", userid: $("#mHost").val())
    $('body').append(upfile.render().el)
    
    category = new Hooful.Views.HoofulsCategory()
    $('.category.btn-group .dropdown-menu').append(category.render().el)
    
    calendar = new Hooful.Views.HoofulsCalendar()
    $('.date .btn').append(calendar.render($('.date .btn').attr("target"), '').el)
    
    map = new Hooful.Views.HoofulsMap()
    $('.place .btn').append(map.render($('.place .btn').attr("target"), '').el)

    ticket_wrap = new Hooful.Views.HoofulsTicketWrap()
    $('div.tickets').append(ticket_wrap.render().el)
    
    $(".addition .sns .btn-auth").click ->
      target = (if ($(this).children("i").attr("class") is "twitter") then "tuid" else "fuid")
      if $(this).hasClass("disabled") is true
        $(this).removeClass "disabled"
        $("#" + target).val 1
      else
        $(this).addClass "disabled"
        $("#" + target).val 0

    $(".pholder").click ->
      target = $(this).attr("target")
      $(this).hide()
      $('#'+target).addClass("set")
      $('#'+target).focus()

    $(".pinput").click ->
      $('.pholder[target="'+$(this).attr("id")+'"]').hide()
      $(this).addClass("set")
      $(this).focus()

    $(".pinput").blur ->
      if $(this).val()
        $(this).addClass("set")
      else
        $(this).removeClass("set")
        $('.pholder[target="'+$(this).attr("id")+'"]').show()

    $(".pinput").keyup (e) ->
      if $(this).val()
        $(this).addClass("set")
      else
        $(this).removeClass("set")
	    
    $(".checkbox").click ->
      status = $(this).hasClass "active"
      target = $(this).attr "target"
      if status
          $(this).removeClass("active").children('input').val 0 unless target
      else
         if target
            chkval = $(this).attr "value"
            $('[target="'+target+'"]').removeClass("active")
            $(this).addClass("active")
            $('#'+target).val chkval
         else
             $(this).addClass("active").children('input').val 1
    edit_validate = new Hooful.Views.HoofulsMeetEditValidate()
    
  meet_withdraw: ->
    manage = new Hooful.Views.HoofulsManageWithdraw()    
  
  meet_manage: (mcode) ->
    manage = new Hooful.Views.HoofulsManagePeople()
    $('.hManageDetail').html(manage.render().el)
    review = new Hooful.Views.HoofulsServiceCommon()

  user_signin: ->
    $(".hInput").focus ->
      $(this).parent().children(".iconsign").css("background-image","none")
      $(this).attr("placeholder","")
    $(".hInput").focusout ->
      $(this).parent().children(".iconsign").removeAttr("style")
      $(this).attr("placeholder",$(this).attr("holder"))
    $(".hInput").keyup (e) ->
      if $(this).val()
        $(this).parent().addClass("set")
      else
        $(this).parent().removeClass("set")

  user_signup_certification: ->
    mobileInfo = new Array("Android", "iPhone", "iPod", "BlackBerry", "Windows CE", "SAMSUNG", "LG", "MOT", "SonyEricsson")
    mcheck = false
    for info of mobileInfo
      if navigator.userAgent.match(mobileInfo[info])?
        mcheck = true
        break;
    if mcheck is false
      upfile = new Hooful.Views.HoofulsUpload(
        type: "certificatioin"
        userid: $("#userid").val()
      )
      $('body').append(upfile.render().el)
    else
      $("#idcard").click (event) ->
        alertTmp("소속사진 업로드는 PC에서만 지원됩니다.")

    $('li.job').click (e) ->
      $('#job').val $(e.currentTarget).text()
      $('#cUsercert .dropdown-toggle').html($(e.currentTarget).text()+"<span class=\"caret\"></span>")
    $("#certSubmit").click ->
      unless $("#certpic").val()
        alert "증명할 사진을 첨부해 주세요." 
        false
        return
      unless $("#job").val()
        alert "직업분류를 선택해 주세요." 
        false
        return
      unless $("#members").val()
        alert "현재 소속을 입력해 주세요." 
        $("#members").focus()
        false
        return
      $("#hUserCert").submit()
  user_signup_complete: ->  
    $(".slides ul").bxSlider
      slideWidth: 1000
      minSlides: 1
      maxSlides: 1
      slideMargin: 0
      auto: false
      autoHover: false
      pause: 5000
      pager: false
      infiniteLoop: false
      nextSelector: ".slider-next"
      prevSelector: ".slider-prev"

  user_signup: ->  
    upfile = new Hooful.Views.HoofulsUpload(
      type: "certificatioin"
      userid: $("#userid").val()
    )
    $('body').append(upfile.render().el)
#    $("#btnSignup").click ->  
#      unless $("#name").val()
#        alert "이름을 입력해 주세요." 
#        $("#name").focus()
#        false
#        return
#      unless $("#userid").val()
#        alert "이메일을 입력해 주세요." 
#        $("#userid").focus()
#        false
#        return
#      unless $("#password").val()
#        alert "비밀번호를 입력해 주세요." 
#        $("#password").focus()
#        false
#        return
#      unless $("#phone").val()
#        alert "휴대폰번호를 입력해 주세요." 
#        $("#phone").focus()
#        false
#        return
#      unless $("#userSex").val()
#        alert "성별을 선택해 주세요." 
#        false
#        return
#      unless $("#userAgree").val() is "1"
#        alert "이용약관 및 개인정보 취급방침에 동의해 주세요." 
#        false
#        return
    $(".hInput").focus ->
      $(this).parent().children(".iconsign").css("background-image","none")
      $(this).attr("placeholder","")
    $(".hInput").focusout ->
      $(this).parent().children(".iconsign").removeAttr("style")
      $(this).attr("placeholder",$(this).attr("holder"))
    $("#local.hInput").click ->
      $('.bgzipcode').show()
      $('.popzipcode').show()
    $(".closebtn").click ->
      $('.bgzipcode').hide()
      $('.popzipcode').hide()
    $("#dong.hInput").keypress (e) ->
      if e.keyCode == 13 or e.keyCode == 3
        @zipcode = new Hooful.Collections.Zipcodes()
        @zipcode.fetch(
          data: {dong:$("#dong.hInput").val()}
          type: "GET"
          success: =>
            $(".zipcodeResult").show()
            zipcode_dong = new Hooful.Views.HoofulsZipcodeDong(@zipcode)
            $('.zipcodeResult').html(zipcode_dong.render().el)
        )
    $("#btnZipcode").click ->
      @zipcode = new Hooful.Collections.Zipcodes()
      @zipcode.fetch(
        data: {dong:$("#dong.hInput").val()}
        type: "GET"
        success: =>
          $(".zipcodeResult").show()
          zipcode_dong = new Hooful.Views.HoofulsZipcodeDong(@zipcode)
          $('.zipcodeResult').html(zipcode_dong.render().el)
      )
    $(".hInput").keyup (e) ->
      if $(this).val()
        $(this).parent().parent().addClass("set")
      else
        $(this).parent().parent().removeClass("set")
    $.gVal = authStatus: "1"
    $('#btnAuthsend').click ->
      if $('#authresult').val() isnt "success"
        unless $('#phone').val()
          alert "휴대전화번호를 입력해 주세요."
          $('#phone').focus()
          return
        unless $('#userid').val()
          alert "이메일을 입력해 주세요."
          $('#userid').focus()
          return
        if $.gVal.authStatus is "1"
          @authsms = new Hooful.Collections.smsauthcode()
          @authsms.fetch(
            data: {phone:$('#phone').val(), userid:$('#userid').val()}
            type: "GET"
            success: =>
              if @authsms.models[0].get('result') is "exist"
                alert "다른 계정에 이미 인증된 번호입니다."
              else if @authsms.models[0].get('result') is "success"
                $('#authresult').val("")
                $('#authresultn').val("")
                alert "인증번호가 입력하신 번호로 전송되었습니다.\n인증번호를 확인해 주세요."
                $.gVal.authStatus = "0"
                $('#btnAuthsend').addClass("send").text("재전송")
                $('#btnAuthsend').attr("disabled", "disabled")
                $('#phone').attr("disabled","disabled")
                $('.authcode').show()
                $('#btnAuthsend').removeAttr("disabled")
                $('#authcode').removeAttr("disabled").val('')
                $('#authcode').val("")
                $('.authmsg').hide()
                window.setTimeout (->
                  $.gVal.authStatus = "1"
                  $("#phone").removeAttr "disabled"
                ), 60000
              else
                alert "다시 시도해 주시기 바랍니다."
          )
        else
          alert "1분후 재전송이 가능합니다."
    $('#btnAuthcheck').click ->
      $('#authresult').val("")
      $('#authresultn').val("")
      unless $("#authcode").val()
        alert "인증번호를 확인해 주세요."
      else
        @authsms = new Hooful.Collections.smsauthcheck()
        @authsms.fetch(
          data: {phone:$('#phone').val(), userid:$('#userid').val(), authcode:$('#authcode').val(),type:'join'}
          type: "GET"
          success: =>
            if @authsms.models[0].get('result') is "success"
              alert "핸드폰 인증이 완료 되었습니다."
              $('#authresult').val("success")
              $('#authresultn').val($('#phone').val())
              $('#btnAuthcheck').text("인증완료")
              $('#btnAuthsend').addClass("complete").text("인증완료")
              $('#authcode').attr("disabled","disabled")
              $('.authmsg').text($('#phone').val()+' 번호로 인증되었습니다.')
              $('.authmsg').show()
              $('.authcode').hide()
            else
              alert "인증번호가 일치하지 않거나 유효시간이 경과하였습니다."
        )
    $("#btnSignup").click ->  
      unless $("#hSigupfrm").valid()
        false
        return
      if $("#userSex").val() is ""
        alert "성별을 선택해 주세요." 
        false
        return
      if $("#authresult").val() is ""
        alert "휴대전화 인증을 해 주세요." 
        false
        return
#      unless $("#hSigupfrm").valid() and $("#userAgree").val() is "1"
#        alert "이용약관 및 개인정보 취급방침에 동의해 주세요." 
#        false
#        return
      $("#hSigupfrm").submit() if $("#hSigupfrm").valid()

    $(".checkbox").click ->
      status = $(this).hasClass "active"
      target = $(this).attr "target"
      if status
          $(this).removeClass("active").children('input').val 0 unless target
      else
         if target
            chkval = $(this).attr "value"
            $('[target="'+target+'"]').removeClass("active")
            $(this).addClass("active")
            $('#'+target).val chkval
         else
             $(this).addClass("active").children('input').val 1


  support_notice: ->
    $("td.title").click ->
      if $(this).parent().hasClass("none")
        that = $(this).parent()
        $(this).parent().next("tr").slideUp 100, ->
          that.removeClass("none")
      else
        that = $(this).parent()
        that.addClass("none")
        that.next("tr").slideDown 500
        

  support_faq: ->
    $("td.title").click ->
      if $(this).parent().hasClass("none")
        that = $(this).parent()
        $(this).parent().next("tr").slideUp 100, ->
          that.removeClass("none")
      else
        that = $(this).parent()
        that.addClass("none")
        that.next("tr").slideDown 500

  support_hooful: ->
    $("#tohoofulSubmit").click ->
      unless $("#title").val()
        alert "제목을 입력해 주세요." 
        $("#title").focus()
        false
        return
      unless $("#article").val()
        alert "내용을 입력해 주세요." 
        $("#article").focus()
        false
        return
      unless $("#email").val()
        alert "이메일을 입력해 주세요." 
        $("#email").focus()
        false
        return
      $("#tohoofulnew").submit()

    $("#askedList .asked .qTitle").click ->
      $this_list = $(this).parents(".asked")
      if $this_list.hasClass("show")
        $("#askedList .asked .answer").each ->
          $(this).hide()  if $(this).attr("idx") is $this_list.attr("idx")

        $this_list.removeClass "show"
      else
        $("#askedList .answer").each ->
          $(this).show()  if $(this).attr("idx") is $this_list.attr("idx")

        $this_list.addClass "show"
  notification_list: ->
    notice_list = new Hooful.Views.HoofulsNotificationList()
    $('#hNotification #hNoticeList').html(notice_list.render().el)


  choice_category: ->
    $("#hInterests li.interest, #hInterests dl.interest").click (e) ->
      if $(this).hasClass("set")
        $(this).removeClass("set")
      else
        $(this).addClass("set")
    $(".btnNext").click ->
      $.gVal = setCategory: "{"
      $("#hInterests li.interest, #hInterests dl.interest").each (e) ->
        if $(this).hasClass("set")
          $.gVal.setCategory += '"'+$(this).attr("category")+'":"1",'
        else
          $.gVal.setCategory += '"'+$(this).attr("category")+'":"0",'
      $.gVal.setCategory = $.gVal.setCategory.substring(0,$.gVal.setCategory.length-1) + "}"

      @setCategory = new Hooful.Collections.SetCategory()
      @setCategory.fetch(
        data: {userid:$('#userid').val(), category:$.gVal.setCategory}
        type: "GET"
        success: =>
          returnurl = $("#direction").val()
          if typeof returnurl is "undefined" or returnurl is ""
            returnurl = "/signup/step3"

          if @setCategory.models[0].get('result') is "success"
            document.location.href = returnurl
          else
            document.location.href = returnurl
      )
    false

  meet_category: (category) ->
    hlike = new Hooful.Views.HoofulsLike()  
  
    dlist = new Hooful.Views.HoofulsCommunityDocument()
    $('.hcDocuments').html(dlist.render().el)
        
    if typeof (userid) is "string" and userid isnt ""
      @group = new Hooful.Collections.GroupCategory({},{gCategory: category})
      @group.fetch(
        data: {gCategory: category, mUserid: userid}
        type: "GET"
        success: =>
          if @group.models.length > 0
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
          else
            gwrap = new Hooful.Views.HoofulsGroupWrap(category: category)
            $('.hcGroupList').html(gwrap.render().el)
            glist = new Hooful.Views.HoofulsGroupList(category: category)
            $('#groupList').html(glist.render().el)
      )
    else
      gwrap = new Hooful.Views.HoofulsGroupWrap(category: category)
      $('.hcGroupList').html(gwrap.render().el)
      glist = new Hooful.Views.HoofulsGroupList(category: category)
      $('#groupList').html(glist.render().el)

    review = new Hooful.Views.HoofulsCommunityReview(category: category)
    
    if typeof (userid) is "string" and userid isnt ""
      @userid = userid
    else
      @userid = ""
    that = @
    $('.docReg').click ->
      $("#community_write_modal").remove()
      review_write = new Hooful.Views.HoofulsCommunityDocumentWrite(type:"docpic",userid:that.userid)
      $('body').append(review_write.render().el)
      $("#community_write_modal").modal()
      $(".redactor").redactor imageUpload: "/api/editorupload?userid=" + userid

    #ticket = new Hooful.Views.HoofulsCommunityTicket
    #$('.hcTicketList').html(ticket.render().el)

  review_write: ->
    upfile = new Hooful.Views.HoofulsUpload(type: "reviewpic", userid: userid)
    $('body').append(upfile.render().el)

    @remeet = new Hooful.Collections.ReviewMeets()
    @remeet.fetch(
      data: {mHost: userid, category:''}
      success: =>
        if @remeet.length > 0
          reOpen = new Hooful.Views.HoofulsReopen(@remeet)
          $('.activity .dropdown-menu').html(reOpen.render().el)
        else
           $('.activity .dropdown-menu').remove()
           $('.activity a').text("참가한 활동이 없습니다.")
    )  
    $(".redactor").redactor imageUpload: "/api/editorupload?userid=" + userid  

    $('.sendReview').click ->
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
          data: {mWriter: $('#mWriter').val(), mCode: $('#mReviewCode').val(), mTitle: $('#mTitle').val(), mReview: $('#mReview').val(), mPicture: $('#mPicture').val(), mPicturename: $('#mPicturename').val()}
          type: "POST"
          success: =>
            if @review.models[0].get('result') is "true"
              alert "활동후기가 작성되었습니다."
              location.href = "/r"
            else if @review.models[0].get('result') is "false"
              alert "오류가 발생했습니다. 후기가 작성되지 않았습니다."
            else
              alert "작성된 내용이 부족합니다. 후기가 작성되지 않았습니다."
        )

  review_detail: ->
    $('.reviewWrite').click ->
      if $('#mComment').val() is ""
        alert "댓글 내용을 입력해 주세요"
      else
        @review_cmt = new Hooful.Collections.ReviewCmts()
        @review_cmt.fetch(
          data: {rCode: $('#rCode').val() , rUserid: userid, rMsg: $('#mComment').val(),lastTalk: $('.comment_list .comment_each:last').attr("rid")}
          type: "POST"
          success: =>
            review_cmt = new Hooful.Views.HoofulsReviewCmt(@review_cmt)
            $('.rcmt .comment_list').append(review_cmt.render().el)
            $('#mComment').val ""
        )

  hope_write: ->
    $(".redactor").redactor imageUpload: "/api/editorupload?userid=" + userid  
    $('.sendReview').click ->
      if $('#mWriter').val() is ""
        alert "로그인이 필요합니다."
      else if $('#mWhen').val() is ""
        alert "언제 하고 싶으세요?"
      else if $('#mWhere').val() is ""
        alert "어디서 하고 싶으세요?"
      else if $('#mWhat').val() is ""
        alert "뭐하고 싶으세요?"
      else if $('#mTitle').val() is ""
        alert "원하시는 활동제목을 입력해 주세요."
      else
        @hope = new Hooful.Collections.Hopes()
        @hope.fetch(
          data: {mWriter: $('#mWriter').val(), mCode: $('#mReviewCode').val(), mTitle: $('#mTitle').val(), mContent: $('#mContent').val(), mWhen: $('#mWhen').val(), mWhere: $('#mWhere').val(), mWhat: $('#mWhat').val(), mPicture: $('#mPicture').val(), mPicturename: $('#mPicturename').val()}
          type: "POST"
          success: =>
            if @hope.models[0].get('result') is "true"
              alert "하고싶어하시는 활동이 작성되었습니다."
              location.href = "/h"
            else if @hope.models[0].get('result') is "false"
              alert "오류가 발생했습니다. 활동이 작성되지 않았습니다."
            else
              alert "작성된 내용이 부족합니다. 활동이 작성되지 않았습니다."
        )

  hope_detail: ->
    $('.reviewWrite').click ->
      if $('#mComment').val() is ""
        alert "댓글 내용을 입력해 주세요"
      else
        @hope_cmt = new Hooful.Collections.HopeCmts()
        @hope_cmt.fetch(
          data: {rCode: $('#rCode').val() , rUserid: userid, rMsg: $('#mComment').val(),lastTalk: $('.comment_list .comment_each:last').attr("rid")}
          type: "POST"
          success: =>
            hope_cmt = new Hooful.Views.HoofulsReviewCmt(@hope_cmt)
            $('.rcmt .comment_list').append(hope_cmt.render().el)
            $('#mComment').val ""
        )

  payment: ->
    payment = new Hooful.Views.HoofulsPayment()
    addresses = new Hooful.Views.HoofulsAddresses(target:"#local")
    $('body').append(addresses.render().el)

  meet_reservation:(mcode, tcode) ->
    $('#hContainer').css('background-color','#f4f4f5')
    if tcode
      @ticketcnt = new Hooful.Collections.detailTicketsold()
      @ticketcnt.fetch(
        data: {tCode:tcode}
        type: "GET"
        success: =>
          tAlert = new Hooful.Views.HoofulsTicketReservation(ticket:@ticketcnt,count:1)
          $('#hReserv').html(tAlert.render().el)
          calendar = new Hooful.Views.HoofulsCalendar()
          $('.date .useDate').append(calendar.render($('.date .useDate').attr("target"), '').el)
      )
    else
      @ticketcnt = new Hooful.Collections.chkChoiceTicketsold()
      @ticketcnt.fetch(
        data: {mCode: $('#hContainer').attr("mcode"), mUserid: $('#hContainer').attr("userid")}
        type: "GET"
        success: =>
          if @ticketcnt.models.count > 1 or @ticketcnt.models[0].get('count') > 1
            tAlert = new Hooful.Views.HoofulsTicketChoiceReservation(ticket:@ticketcnt,count:1)
            $('#hReserv').html(tAlert.render().el)
          else if @ticketcnt.models.count is 1 or @ticketcnt.models[0].get('count') is 1
            tAlert = new Hooful.Views.HoofulsTicketReservation(ticket:@ticketcnt,count:1)
            #tAlert = new Hooful.Views.HoofulsTicketChoiceReservation(@ticketcnt)
            $('#hReserv').html(tAlert.render().el)
            calendar = new Hooful.Views.HoofulsCalendar()
            $('.date .useDate').append(calendar.render($('.date .useDate').attr("target"), '').el)
          else
            alert "예약 가능한 티켓이 없습니다."
            history.go(-1)
      )
  review_show:(rid) ->
    @review = new Hooful.Collections.ReviewDetail({},{id: rid})
    @review.fetch(
      type: "GET"
      success: =>
        review_detail = new Hooful.Views.HoofulsReviewDetail(@review)
        $('#hReview').append(review_detail.render().el)
        $("#review_modal").removeClass("hide fade in").css({'position':'static','margin':'0 auto','margin-bottom':'60px'})
        review_wrap = new Hooful.Views.HoofulsReviewCmtWrap(rCode: rid)
        $('#review_modal .modal-footer').html(review_wrap.render().el)
        @isSending = false
    )
  group_show:(gid) ->
    if typeof (userid) is "string" and userid isnt ""
      @group = new Hooful.Collections.Group({},{gid: gid})
      @group.fetch(
        data: {gid: gid}
        type: "GET"
        success: =>
          if @group.models.length > 0
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
            $('#hGroup').html(group_talk.render().el)
            if $('#hGroup').attr("valid") is "false"
              $('#groupTalk .mCancel').remove()
              $('#groupTalk .talkWrap').remove()
              notingroup = new Hooful.Views.HoofulsNotInGroup()
              $('#groupTalk .groupBody').prepend(notingroup.render().el)
        )
    else
      alertMove("로그인 이후 이용 가능합니다.","/signin","/g/"+gid)

