class Hooful.Views.HoofulsTicket extends Backbone.View
  template: JST['hoofuls/ticket']
  tagName: 'tr'
  events:
    'click span.description': 'toggleDescription'
    'click .checkbox': 'checkBox'
    'click .tholder': 'holderHide'
    'click .ticket_name': 'inputHide'
    'blur .ticket_name': 'inputBlur'
    'keyup .ticket_name': 'inputKeyup'

  initialize: ->
    $(".tickets .add .btn.free").addClass "active"  if $(".tickets .add .btn").hasClass("active") is false

  render: ->
    $(@el).html(@template())
    this


  toggleDescription: (event) ->
    target = $(event.target).parent().next().next()
    if target.css("display") is "none"
      $(event.target).html "설정&#9650;"
    else
      $(event.target).html "설정&#9660;"

    target.slideToggle()

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

  holderHide: (event) ->
      idx = $('.tholder').index(event.target)
      $(event.target).hide()
      $('.ticket_name:eq('+idx+')').addClass("set")
      $('.ticket_name:eq('+idx+')').focus()

  inputHide: (event) ->
      idx = $('.ticket_name').index(event.target)
      $('.tholder:eq('+idx+')').hide()
      $(event.target).addClass("set")
      $(event.target).focus()

  inputBlur: (event) ->
      idx = $('.ticket_name').index(event.target)
      if $(event.target).val()
        $(event.target).addClass("set")
      else
        $(event.target).removeClass("set")
        $('.tholder:eq('+idx+')').show()

  inputKeyup: (event) ->
      if $(event.target).val()
        $(event.target).addClass("set")
      else
        $(event.target).removeClass("set")

class Hooful.Views.HoofulsTicketWrap extends Backbone.View
  template: JST['hoofuls/ticket_wrap']

  events:
    'click .add .btn': 'payType'
    'click #addTicket': 'addTicket'
    'click table .close': 'deleteTicket'

  initialize: ->
    @paytype = "free"

  render: ->
    $(@el).html(@template())
    this

  payType: (event) ->
    $(".tickets .add .btn").removeClass "active"
    $(event.target).addClass "active"
    if $(event.target).hasClass "pay" 
      $('#paySelect').show()
      $(".ticket_price").attr("type","text").attr("value",0).parent().find("span").hide()
      $(".ticket_supply_price").attr("type","text").attr("value",0).parent().find("span").hide()
      @paytype = "pay"
      $('#mPayUse').val 1
    else
      $('#paySelect').hide()
      $(".ticket_price").attr("type","hidden").attr("value",0).parent().find("span").show()
      $(".ticket_supply_price").attr("type","hidden").attr("value",0).parent().find("span").show()
      @paytype = "free"
      $('#mPayUse').val 0
  
  addTicket: (event) ->
    @paytype = if $('#mPayUse').val() is "1" then "pay" else "free"
    ticket = new Hooful.Views.HoofulsTicket()
    $('.tickets table:eq(0) tbody').append(ticket.render().el)
    if @paytype is "free"
      $(".ticket_price").attr("type","hidden").attr("value",0).parent().find("span").show()
      $(".ticket_supply_price").attr("type","hidden").attr("value",0).parent().find("span").show()
      
  deleteTicket: (event) ->
    if $('.tickets table:eq(0) tbody tr').length > 1
     $(event.target).parent("div").parent("td").slideUp "fast", ->
         $(this).parent("tr").remove()

class Hooful.Views.HoofulsTicketCheck extends Backbone.View

  initialize: ->
    _.bindAll(this, 'ticketSubmit', 'ticketCheck')
    that = @
    $("input[type=submit]").click (e) -> that.ticketSubmit(e)

  render: ->

  showMessage: (message) ->
    alertView(message)

  ticketSubmit: (e) ->
    if $('#mUserid').val() is ""
      alertMove("로그인 이후 이용 가능합니다.","/signin","/"+$('#mCode').val())
      return false
    else if $(e.target).hasClass("false")
        @showMessage("인원이 마감되어 대기자로 등록됩니다.")
        setTimeout("",1000*2)
        return true    
    else
      if @ticketCheck() is false
        @showMessage("티켓을 선택해 주세요")
        return false
      else
        return true

  ticketCheck: ->
    ticketcount = 0
    unitprice = 0
    ticketInfo = ""
    set = true
    $(".ticket_name").each (index) ->
      ticket_quantity = $(".ticket_quantity:eq(" + index + ")").val()
      ticket_price = $(".ticket_price:eq(" + index + ")").val()
      ticket_supply_price = $(".ticket_supply_price:eq(" + index + ")").val()
      ticket_id = $(".ticket_id:eq(" + index + ")").val()
      ticket_name = $(".ticket_name:eq(" + index + ")").val()
      ticket_description = $(".ticket_description:eq(" + index + ")").val()
      ticket_designated = $(".ticket_designated:eq(" + index + ")").val()
      
      unitprice += parseInt(ticket_quantity) * parseInt(ticket_price) 
      ticketcount+= parseInt(ticket_quantity)
      ticketInfo += ticket_id + "/+/"+ ticket_name + "/+/" + ticket_price + "/+/" + ticket_quantity + "/,/" + ticket_description + "/,/" + ticket_designated + "/,/" + ticket_supply_price + "/,/"
      
    if ticketcount is 0 and set is true
      @showMessage("티켓을 선택해 주세요")
      set = false
    else
      $("#unitprice").val unitprice
      
    return set
    
class Hooful.Views.HoofulsTicketChoiceReservation extends Backbone.View

  template: JST['hoofuls/ticket_choice']
  tagName: 'div'

  events:
    'click .tReserv tr' : 'selectTicket'
    'click .btnNext' : 'nextReservation'
    
  initialize: ->
    
  render:(size) ->
    $(@el).html(@template(ticket: @options.ticket.models))
    this

  selectTicket: (e) ->
    if $(e.currentTarget).hasClass 'set'
      $(e.currentTarget).removeClass('set') 
    else
      $('.tReserv tr').each ->
        $(this).removeClass('set')
      $(e.currentTarget).addClass('set')

  nextReservation: ->
    $.gVal = tIdx: 0, tCnt:0
    $('.tReserv tr').each (index) ->
      if $(this).hasClass('set')
        $.gVal.tIdx += index
        $.gVal.tCnt = $(this).children('td.cnt').children('.quantity').val()
    if $.gVal.tIdx is 0
      alert "예약할 티켓을 선택해 주세요."
    else
      tAlert = new Hooful.Views.HoofulsTicketReservation(ticket:@options.ticket,count:$.gVal.tCnt)
      $('#hReserv').html(tAlert.render($.gVal.tIdx).el)
      calendar = new Hooful.Views.HoofulsCalendar()
      $('.date .useDate').append(calendar.render($('.date .useDate').attr("target"), '').el)
    
    
class Hooful.Views.HoofulsTicketReservation extends Backbone.View

  template: JST['hoofuls/ticket_reservation']
  tagName: 'div'

  events:
    'click .btnNext' : 'saveReservation'
    'click .useTimelist li' : 'setUsetime'
    
  initialize: ->
    
  render:(size) ->
    if eval(size) > 0
      idx = size-1
    else
      idx = 0
    $(@el).html(@template(ticket: @options.ticket.models[0], tid:@options.ticket.models[0].get('tId'), count:@options.count))
    this

  saveReservation: ->
    unless $('#tUseDate').val()
      alert "예약날짜를 선택해 주세요."
      false
      return
    unless $('#tUseTime').val()
      alert "예약시간을 선택해 주세요."
      false
      return
    @ticketcnt = new Hooful.Collections.reservCode()
    @ticketcnt.fetch(
      data: {state:'1', tCode: $('#tCode').val(), tState: $('#tState').val(), mCode: $('#mCode').val(), mHost: $('#hContainer').attr('userid'), tUseDate: $('#tUseDate').val(), tUseTime: $('#tUseTime').val(), tReserveText: $('#tReserveText').val(), tid:@options.ticket.models[0].get('tId'), count:@options.count}
      type: "GET"
      success: =>
        if @ticketcnt.models[0].get('tState') > 1
          tAlert = new Hooful.Views.HoofulsTicketReservationEnd(@ticketcnt)
          $('#hReserv').html(tAlert.render().el)
        else
          tAlert = new Hooful.Views.HoofulsTicketReservationEnd(@ticketcnt)
          $('#hReserv').html(tAlert.render().el)
    )

  setUsetime: (e) ->
    $('.tTime').text($(e.currentTarget).text())
    $('#tUseTime').val($(e.currentTarget).attr('value'))


class Hooful.Views.HoofulsTicketReservationEnd extends Backbone.View

  template: JST['hoofuls/ticket_reservationend']
  tagName: 'div'
    
  initialize: ->
    
  render:(size) ->
    $(@el).html(@template(ticket: @options.models[0]))
    this

class Hooful.Views.HoofulsUserTicket extends Backbone.View

  template: JST['hoofuls/ticket_user']
  tagName: 'div'

  events:
    'click .more': 'loadMore'

  initialize: ->
    _.bindAll(this, 'loadTicket')
    @loadTicket()

  render: ->
    $(@el).html(@template(ticket: @ticket, S3ADDR: @S3ADDR))
    this

  loadTicket: ->
    @ticket = new Hooful.Collections.Tickets()
    @ticket.fetch(
      data: {mUserid: @options.mUserid, lastTicket: $('#uTicket dd .hPrintTicket:last').attr('tid')}
      type: "GET"
      success: =>
        if $('#uTicket dd ul').length is 0
          if @ticket.models.length < 9
             $('#uTicket dt .number').text "("+ @ticket.models.length + ")"
          else
            $('#uTicket dt .number').text "("+ @ticket.models[@ticket.models.length-1].get('next') + ")"
         @render()
    )

  loadMore: ->
    if !@isLoading
      user_ticket = new Hooful.Views.HoofulsUserTicket(mUserid: @options.mUserid)
      $('#uTicket dd .more').remove()
      $('#uTicket dd').append(user_ticket.render().el)
 