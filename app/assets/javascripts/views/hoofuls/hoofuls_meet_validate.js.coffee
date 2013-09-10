class Hooful.Views.HoofulsMeetValidate extends Backbone.View

  initialize: ->
    _.bindAll(this, 'meetSubmit','codeValid','ticketCheck','limitDate')
    $("input[type=submit]").click @meetSubmit
    @limitDate()
    $("#mDate").change @limitDate
    $("#mCode").keyup @codeValid

    @remeet = new Hooful.Collections.ReMeets()
    @remeet.fetch(
      data: {mHost: $('#mHost').val()}
      success: =>
        reopen = new Hooful.Views.HoofulsReopen(@remeet)
        $('#reOpen .dropdown-menu').html(reopen.render().el)
    )  

  render: ->

  meetSubmit: (event) ->
    set = false
    
    if $("#mPicture").val() is ""
      @showMessage("이미지를 등록해 주세요.")
    else if $("#mCategory").val() is ""
      @showMessage("카테고리를 선택해 주세요.")
    else if $("#mTitle").val() is ""
      @showMessage("제목을 입력해 주세요.")
    else if $("#mDate").val() is ""
      @showMessage("날짜를 입력해 주세요.")
    else if $("#mTimeS").val() is ""
      @showMessage("활동 시작시간을 입력해 주세요.")
    else if $("#mTimeE").val() is ""
     @showMessage("활동 종료시간을 입력해 주세요.")
    else if $("#mPlace").val() is ""
      @showMessage("장소를 입력해 주세요.")
    else if $("#mDescription").val() is ""
      @showMessage("활동 상세내용을 입력해 주세요.")
    else if @ticketCheck() is false
      #@showMessage("티켓 정보를 입력해 주세요")
    else if $("#mCode").val() is ""
      @showMessage("URL을 입력해 주세요.")
    else
      @codeValid(1)
      if $('#mCodeValid').val() is '1'
        set = true
    return set

  ticketCheck: ->
    ticketcount = 0
    payUse = $('#mPayUse').val()
    set = true
    parent_this = @
    $(".ticket_name").each (index) ->
      if payUse isnt '1'
        if $(this).val() is "" 
          parent_this.showMessage("티켓명이 누락되었습니다.")
          set = false
        else if parseInt($(".ticket_quantity:eq(" + index + ")").val()) <= 0 
          parent_this.showMessage("티켓 수량이 누락되었습니다.")
          set = false
        else
          ticketcount++  
      else
        if $(this).val() is "" 
          parent_this.showMessage("티켓명이 누락되었습니다.")
          set = false
        else if parseInt($(".ticket_quantity:eq(" + index + ")").val()) <= 0 
           parent_this.showMessage("티켓 수량이 누락되었습니다.")
           set = false
        else if parseInt($(".ticket_price:eq(" + index + ")").val()) <= 0
          parent_this.showMessage("티켓 금액이 누락되었습니다.")
          set = false
        else if parseInt($(".ticket_supply_price:eq(" + index + ")").val()) <= 0
          parent_this.showMessage("티켓 공급가가 누락되었습니다.")
          set = false
        else
          ticketcount++

    if ticketcount is 0 and set is true
      @showMessage("티켓 정보를 입력해 주세요")
      set = false
    else if payUse isnt '0' and $('#mPaytype_card').val() is "0" and $('#mPaytype_801').val() is "0"
      @showMessage("결제방식을 하나 이상 선택해 주세요")
      set = false

    return set


  showMessage: (message) ->
    alertView(message)

  limitDate: ->
     if $("#mDate").val()
       if Date.parse($("#mDate").val()) > Date.parse($("#mDateE").val())
         $("#mDateE").val ""
         
       $("#mDateE").attr "limit", $("#mDate").val()
       $('.date .btn[target=mDateE]').each ->
         target = $(this).attr "target"
         limit = $("#" + target).attr "limit"
         date = $(this).find(".calendar .contents")
         
         date.find(".date.limitdate").removeClass('disabled').removeClass('limitdate')
       
         startdate = date.find(".date:not('.disabled')").attr "date"
         enddate = date.find(".date:not('.disabled'):last").attr "date"
         if limit and Date.parse(limit) > Date.parse(startdate) and Date.parse(limit) < Date.parse(enddate)
           date.children(".date:not('.disabled')").each ->
             if Date.parse($(this).attr "date") < Date.parse(limit)
                $(this).addClass("disabled").addClass("limitdate")
       
     else
       $('.date .btn').each ->
         target = $(this).attr "target"
         limit = $("#" + target).attr "limit"
         date = $(this).find(".calendar .contents")       
         startdate = date.find(".date:not('.disabled')").attr "date"
         enddate = date.find(".date:not('.disabled'):last").attr "date"
         if limit and Date.parse(limit) > Date.parse(startdate) and Date.parse(limit) < Date.parse(enddate)
           date.children(".date:not('.disabled')").each ->
             if Date.parse($(this).attr "date") < Date.parse(limit)
                $(this).addClass("disabled").addClass("limitdate")
           
   codeValid: (set) ->
     if $("#mCode").val() isnt ""
       $('#mCode').val $('#mCode').val().replace /[^a-zA-Z 0-9]+/g, ""
       @meet = new Hooful.Collections.Validmeets({},{mcode: $('#mCode').val()})
       @meet.fetch(success: =>
         if @meet.models[0].get('count') is 1
           $('#mCodeValid').val 0
           if set is 1
             @showMessage("이미 존재하는 URL입니다.")
             $('#mCode').val "" 
             return false
           else
             $('#mCode').addClass("invalid")
         else
           $('#mCode').removeClass("invalid")
           $('#mCodeValid').val 1
       )      


class Hooful.Views.HoofulsReopen extends Backbone.View
  template: JST['hoofuls/reopen']
  tagName: 'div'

  events:
    'click li': 'fillForm'

  initialize: ->

  render: ->
    $(@el).html(@template(meet: @options))
    this
  
  fillForm: (event)->
    if $(event.target).closest("form").attr("id") is "hReviewfrm"

      target = $(event.target).attr "text"
      code = $(event.target).attr "code"
      $("#mReviewCode").val code
      $(".activity .dropdown-toggle").html($(event.target).text()+"<span class=\"caret\"></span>")
      $(".activity .dropdown-menu li").removeClass("active")
      $(event.target).addClass("active")
    
    else
      index = $('#reOpen .dropdown-menu li').index($(event.target))
      $('#mCategory').val @options.models[index].get('mCategory')
      cat_li = $('.category .dropdown-menu li.interest i[class='+@options.models[index].get('mCategory')+']').parent('li')
      cat_li.addClass('active')
      $(".category .dropdown-toggle").html(cat_li.text()+"<span class=\"caret\"></span>")

      $('#mTitle').click().val @options.models[index].get('mTitle')
      $('#mPlace').click().val @options.models[index].get('mPlace')
      $('#mAddress').click().val @options.models[index].get('mAddress')
      $('#mLat').val @options.models[index].get('mLat')
      $('#mLng').val @options.models[index].get('mLng')
  
      po = new daum.maps.LatLng($("#mLat").val(), $("#mLng").val())
      marker = new daum.maps.Marker(position: po)
      marker.setMap map
      map.setCenter po
  
      $('#mDescription').val @options.models[index].get('mDescription')
      $('#mPicture').val @options.models[index].get('mPicture')
      $('#mPicturename').val @options.models[index].get('mPicturename')
      $("#uploadURL").val $("#mPicture").val()
      $("#uploadvURL").val $("#mPicturename").val()
      $("#uploadForm .preview").attr("src", "http://d3o755op057jl1.cloudfront.net/" + $("#uploadForm #uploadPath").val() + "/" + $("#mPicture").val()).css("border", "1px solid #A8A8A8").css("padding", "0").css("width", "320px").css "height", "240px"
      $(".picture img").attr "src", $("#uploadForm .preview").attr("src")
  
      $('#mPayUse').val @options.models[index].get('mPayUse')
      payuse = if $('#mPayUse').val() is "1" then "pay" else "free"
      $(".tickets .add .btn").removeClass "active"
      $(".tickets .add .btn."+payuse).addClass "active"
      if payuse is "pay" 
        $('#paySelect').show()
        $(".ticket_price").attr("type","text").attr("value",0).parent().find("span").hide()
        $(".ticket_supply_price").attr("type","text").attr("value",0).parent().find("span").hide()
      else
        $('#paySelect').hide()
        $(".ticket_price").attr("type","hidden").attr("value",0).parent().find("span").show()
        $(".ticket_supply_price").attr("type","text").attr("value",0).parent().find("span").hide()
      $('#mPaytype').val @options.models[index].get('mPaytype')
      for num in [parseInt(@options.models[index].get('mTicket').length)..parseInt($(".tickets table tbody tr").length-2)]
        if parseInt(@options.models[index].get('mTicket').length) > parseInt($(".ticket_name").length)
          ticket = new Hooful.Views.HoofulsTicket()
          $('.tickets table:eq(0) tbody').append(ticket.render().el)
        else
          $(".tickets table tbody tr:eq(0)").remove()
      cnt = 0
      for ticket in @options.models[index].get('mTicket')
        $('.ticket_name:eq('+cnt+')').click().val ticket.tName
        $('.ticket_quantity:eq('+cnt+')').val ticket.tQuantity
        $('.ticket_price:eq('+cnt+')').val ticket.tPrice
        $('.ticket_supply_price:eq('+cnt+')').val ticket.tSupplyPrice
        $('.ticket_description:eq('+cnt+')').val ticket.tDescription
        cnt++
class Hooful.Views.HoofulsMeetEditValidate extends Backbone.View

  initialize: ->
    _.bindAll(this, 'meetSubmit','ticketCheck','limitDate')
    $("input[type=submit]").click @meetSubmit
    @limitDate()
    $("#mDate").change @limitDate
    $("#mCode").keyup @codeValid

    @remeet = new Hooful.Collections.ReMeets()
    @remeet.fetch(
      data: {mHost: $('#mHost').val()}
      success: =>
        reopen = new Hooful.Views.HoofulsReopen(@remeet)
        $('#reOpen .dropdown-menu').html(reopen.render().el)
    )
    po = new daum.maps.LatLng($("#mLat").val(), $("#mLng").val())
    marker = new daum.maps.Marker(position: po)
    marker.setMap map
    map.setCenter po

    $("#uploadURL").val $("#mPicture").val()
    $("#uploadvURL").val $("#mPicturename").val()
    $("#uploadForm .preview").attr("src", "http://d3o755op057jl1.cloudfront.net/" + $("#uploadForm #uploadPath").val() + "/" + $("#mPicture").val()).css("border", "1px solid #A8A8A8").css("padding", "0").css("width", "320px").css "height", "240px"
    $(".picture img").attr "src", $("#uploadForm .preview").attr("src")

    payuse = if $('#mPayUse').val() is "1" then "pay" else "free"
    $(".tickets .add .btn").removeClass "active"
    $(".tickets .add .btn."+payuse).addClass "active"
    if payuse is "pay" 
      $('#paySelect').show()
      $(".ticket_price").attr("type","text").attr("value",0).parent().find("span").hide()
      $(".ticket_supply_price").attr("type","text").attr("value",0).parent().find("span").hide()
    else
      $('#paySelect').hide()
      $(".ticket_price").attr("type","hidden").attr("value",0).parent().find("span").show()
      $(".ticket_supply_price").attr("type","text").attr("value",0).parent().find("span").hide()

    @ticket = new Hooful.Collections.Tickets()
    @ticket.fetch(
      data: {mCode: $('#mCode').val()}
      type: "GET"
      success: =>
        cnt = 0
        for ticket in @ticket.models 
          ticket_template = new Hooful.Views.HoofulsTicket()
          $('.tickets table:eq(0) tbody').append(ticket_template.render().el)
          $('.ticket_name:eq('+cnt+')').before("<input class=\"ticket_id\" name=\"ticket_id[]\" value=\""+ticket.get('_id')+"\" type=\"hidden\">")
          $('.ticket_name:eq('+cnt+')').click().val ticket.get('tName')
          $('.ticket_quantity:eq('+cnt+')').val ticket.get('tQuantity')
          $('.ticket_price:eq('+cnt+')').val ticket.get('tPrice')
          $('.ticket_origin_price:eq('+cnt+')').val ticket.get('tOriginPrice')
          $('.ticket_supply_price:eq('+cnt+')').val ticket.get('tSupplyPrice')
          $('.ticket_description:eq('+cnt+')').val ticket.get('tDescription')
          $('.ticket_designated:eq('+cnt+')').val ticket.get('tDesignated')
          if $('.ticket_designated:eq('+cnt+')').val() is "1"
            $('.ticket_designated:eq('+cnt+')').parent(".checkbox").addClass("active").val ticket.get('tDesignated')
          if $('.ticket_designated:eq('+cnt+')').val() is "1" and $('.ticket_description:eq('+cnt+')').val() isnt ""
            $('.ticket_description:eq('+cnt+')').parent().parent(".description").show() 
          cnt++
    )

  render: ->

  meetSubmit: (event) ->
    set = false
    
    if $("#mPicture").val() is ""
      @showMessage("이미지를 등록해 주세요.")
    else if $("#mCategory").val() is ""
      @showMessage("카테고리를 선택해 주세요.")
    else if $("#mTitle").val() is ""
      @showMessage("제목을 입력해 주세요.")
    else if $("#mDate").val() is ""
      @showMessage("날짜를 입력해 주세요.")
    #else if $("#mTimeS").val() is ""
    #  @showMessage("활동 시작시간을 입력해 주세요.")
    #else if $("#mTimeE").val() is ""
    # @showMessage("활동 종료시간을 입력해 주세요.")
    else if $("#mPlace").val() is ""
      @showMessage("장소를 입력해 주세요.")
    else if $("#mDescription").val() is ""
      @showMessage("활동 상세내용을 입력해 주세요.")
    else if @ticketCheck() is false
      #@showMessage("티켓 정보를 입력해 주세요")
    else
      set = true
    return set

  ticketCheck: ->
    ticketcount = 0
    payUse = $('#mPayUse').val()
    set = true
    parent_this = @
    $(".ticket_name").each (index) ->
      if payUse isnt '1'
        if $(this).val() is "" 
          parent_this.showMessage("티켓명이 누락되었습니다.")
          set = false
        else if parseInt($(".ticket_quantity:eq(" + index + ")").val()) <= 0 
          parent_this.showMessage("티켓 수량이 누락되었습니다.")
          set = false
        else
          ticketcount++  
      else
        if $(this).val() is "" 
          parent_this.showMessage("티켓명이 누락되었습니다.")
          set = false
        else if parseInt($(".ticket_quantity:eq(" + index + ")").val()) <= 0 
           parent_this.showMessage("티켓 수량이 누락되었습니다.")
           set = false
        else if parseInt($(".ticket_price:eq(" + index + ")").val()) <= 0
          parent_this.showMessage("티켓 금액이 누락되었습니다.")
          set = false
        else if parseInt($(".ticket_supply_price:eq(" + index + ")").val()) <= 0
          parent_this.showMessage("티켓 공급가가 누락되었습니다.")
          set = false
        else
          ticketcount++

    if ticketcount is 0 and set is true
      @showMessage("티켓 정보를 입력해 주세요")
      set = false
    else if payUse isnt '0' and $('#mPaytype_card').val() is "0" and $('#mPaytype_801').val() is "0"
      @showMessage("결제방식을 하나 이상 선택해 주세요")
      set = false

    return set


  showMessage: (message) ->
    alert message

  limitDate: ->
       if Date.parse($("#mDate").val()) > Date.parse($("#mDateE").val())
         $("#mDateE").val ""
         
       $("#mDateE").attr "limit", $("#mDate").val().replace(",","")
       $('.date .btn[target=mDateE], .date .btn[target=mDateG]').each ->
         target = $(this).attr "target"
         limit = $("#" + target).attr "limit"
         date = $(this).find(".calendar .contents")
         value = $("#"+ target).val() 
         date.find(".date.limitdate").removeClass('disabled').removeClass('limitdate')
       
         startdate = date.find(".date:not('.disabled')").attr "date"
         enddate = date.find(".date:not('.disabled'):last").attr "date"
         date.find(".date").removeClass("active")
         if limit and Date.parse(limit) > Date.parse(startdate) and Date.parse(limit) < Date.parse(enddate)
           date.children(".date:not('.disabled')").each ->
             if Date.parse($(this).attr "date") < Date.parse(limit)
                $(this).addClass("disabled").addClass("limitdate")
             if value.indexOf($(this).attr("date")+", ") isnt -1
               $(this).addClass("active")
