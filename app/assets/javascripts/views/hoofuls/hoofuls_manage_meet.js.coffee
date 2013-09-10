class Hooful.Views.HoofulsManageMeet extends Backbone.View

  template: JST['hoofuls/manage_meet']
  tagName: 'span'

  initialize: ->
    this.isNow = 'person'
    this.isType = 'participants'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    this.order = 'name'
    this.sort = 'desc'
    this.iskeyword = ''
    @setCheck = '0'
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'changeManage', 'changeParticipants','keySearch')
    @doRender()

  events:
    'click .hdmParticipants' : 'changeParticipants'
    'click .hdmWaittings' : 'changeWaittings'
    'click .btnAll' : 'selectAll'
    'click .hPerson tr' : 'selectUser'
    'click i.iCheckup' : 'setCheckk'
    'click i.iCheck' : 'setCheckk'
    'click i.iChecked' : 'setChecked'
    'click i.iChange' : 'setChange'
    'click i.iPhone' : 'setPhone'
    'click i.iEmail' : 'setEmail'
    'click i.iRemove' : 'setRemove'
    'click i.iArrowdown' : 'setOrderAsc'
    'click i.iArrowup' : 'setOrderDesc'
    'keyup #meetSearch' : 'keySearch'

  render: (target) ->
    $(@el).html(@template(status: @status, mcode: this.mcode))
    this

  doRender: ->
    @status = new Hooful.Collections.Managecnt({},{type: this.isNow, mcode: this.mcode, mhost: this.mhost})
    @status.fetch(success: =>
      @render()
      @loadPerson()
    )

  loadPerson: ->
    manage_person = new Hooful.Views.HoofulsManagePerson(
      type: this.isType,
      mcode: this.mcode,
      mhost: this.mhost,
      order: this.order,
      sort: this.sort,
      keyword: this.iskeyword
    )
    print = new Hooful.Views.HoofulsMeetPrint()
    $('body').append(print.render().el)

  changeManage: (e) ->
    $(".ulink").each ->
      $(this).removeClass "current"
    if $(e.currentTarget).attr('type') is "person"
      this.isNow = "person"
      @loadPerson()
    else if $(e.currentTarget).attr('type') is "ticket"
      this.isNow = "ticket"
      @loadTicket()
    else if $(e.currentTarget).attr('type') is "report"
      this.isNow = "report"
      @loadReport()
    
  changeParticipants: (e) ->
    this.isType = 'participants'
    this.iskeyword = ''
    $('#meetSearch').val("")
    @loadPerson()
    
  changeWaittings: (e) ->
    this.isType = 'waittings'
    this.iskeyword = ''
    $('#meetSearch').val("")
    @loadPerson()
  
  selectAll: (e) ->
    $(e.currentTarget).parent().parent().parent().next("tbody").attr("side","0")
    if $(e.currentTarget).hasClass "set"
      $("#hTable .hPerson > tr").each ->
        $(this).toggleClass "set" if $(this).hasClass("set")
      $(e.currentTarget).toggleClass "set"
      $('.hSidecontrol').fadeOut()
      $(e.currentTarget).parent().parent().parent().next("tbody").attr("side","0")
    else
      $("#hTable .hPerson > tr").each ->
        $(this).toggleClass "set"  unless $(this).hasClass("set")
      $(e.currentTarget).toggleClass "set"
      $('.hSidecontrol').fadeIn()
      $(e.currentTarget).parent().parent().parent().next("tbody").attr("side","1")
    $('.hSidecontrol').fadeOut() if $(e.currentTarget).parent().parent().parent().next("tbody").attr("side") is '0' and $('.hSidecontrol').css("display") is "block"

  selectUser: (e) ->
    $(e.currentTarget).toggleClass "set"
    $(e.currentTarget).parent().attr("side","0")
    $("#hTable .hPerson > tr").each ->
      if $(this).hasClass("set")
        $('.hSidecontrol').fadeIn()
        $(e.currentTarget).parent().attr("side","1")
    if $(e.currentTarget).parent().attr("side") is '0' and $('.hSidecontrol').css("display") is "block"
      $('.hSidecontrol').fadeOut()
      $('.btnAll').removeClass "set"
    return
    false

  setOrderAsc: (e) ->
    this.order = $(e.currentTarget).attr("order")
    
    if $(e.currentTarget).hasClass("set")
      this.sort = "asc"
      $(e.currentTarget).removeClass("iArrowdown").addClass("iArrowup")
    else
      this.sort = "desc"
    $(".iArrowup.set").removeClass("set")
    $(".iArrowdown.set").removeClass("set")
    $(e.currentTarget).addClass("set")
    @loadPerson()
    
  setOrderDesc: (e) ->
    this.order = $(e.currentTarget).attr("order")
    
    if $(e.currentTarget).hasClass("set")
      this.sort = "desc"
      $(e.currentTarget).removeClass("iArrowup").addClass("iArrowdown")
    else
      this.sort = "asc"
    $(".iArrowup.set").removeClass("set")
    $(".iArrowdown.set").removeClass("set")
    $(e.currentTarget).addClass("set")
    @loadPerson()
  
  setCheckk: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    @tcode = $(e.currentTarget).parent().parent().attr "tcode"
    unless $(e.currentTarget).hasClass("list")
      if $(e.currentTarget).parent().parent().attr("use") is "1"
        @nowstate = 'checkdown'
      else
        @nowstate = 'checkup'
    
      @userstate = new Hooful.Collections.Userstate({},{type: @nowstate, userid: @userid, tCode: @tcode})
      @userstate.fetch(success: =>
        $(e.currentTarget).parent().parent().attr "use", @userstate.models[0].get('tUse')
        if @userstate.models[0].get('tUse') is 1
          $(e.currentTarget).removeClass("iCheck").addClass("iCheckup")
          $(e.currentTarget).parent().children(".udate").text(@userstate.models[0].get('tUseDate'))
        else
          $(e.currentTarget).removeClass("iCheckup").addClass("iCheck")
          $(e.currentTarget).parent().children(".udate").text("")
      )
      false

  setCheck: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    @tcode = $(e.currentTarget).parent().parent().attr "tcode"
    unless $(e.currentTarget).hasClass("list")
      if $(e.currentTarget).parent().parent().attr("use") is "1"
        @nowstate = 'checkdown'
      else
        @nowstate = 'checkup'
    
      @userstate = new Hooful.Collections.Userstate({},{type: @nowstate, userid: @userid, tCode: @tcode})
      @userstate.fetch(success: =>
        $(e.currentTarget).parent().parent().attr "use", @userstate.models[0].get('tUse')
        if @userstate.models[0].get('tUse') is "1"
          $(e.currentTarget).removeClass("iCheck").addClass("iCheckup")
        else
          $(e.currentTarget).removeClass("iCheckup").addClass("iCheck")
      )
      false

  setChange: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    unless $(e.currentTarget).hasClass("list")
      if $(e.currentTarget).parent().parent().attr("state") is "1"
        @nowstate = 'statedown'
      else
        @nowstate = 'stateup'
    
      @userstate = new Hooful.Collections.Userstate({},{type: @nowstate, userid: @userid, mcode: this.mcode})
      @userstate.fetch(success: =>
        $(e.currentTarget).parent().parent().attr "check", @userstate.models[0].get('mCheck')
        if @userstate.models[0].get('_id')
          $(e.currentTarget).parent().parent("tr").fadeOut 500, ->
            $(this).remove()
        @doRender()
      )
      false
    else
      alert "side change"

  setChecked: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    unless $(e.currentTarget).hasClass("list")
    else
      alert "side checked"

  setEmail: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    unless $(e.currentTarget).hasClass("list")
    else
      alert "side email"

  setPhone: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    unless $(e.currentTarget).hasClass("list")
    else
      alert "side phone"

  setRemove: (e) ->
    @userid = $(e.currentTarget).parent().parent().attr "userid"
    unless $(e.currentTarget).hasClass("list")
    else
      alert "side remove"

  keySearch: (e) ->
    this.iskeyword= $('#meetSearch').val()
    @loadPerson()

class Hooful.Views.HoofulsMeetViewlink extends Backbone.View
  template: JST['hoofuls/meet_view']
  tagName: 'div'

  events:
    'click li': 'linkView'

  initialize: ->

  render: ->
    $(@el).html(@template(meet: @options))
    this

  linkView: (e) ->
    window.open('/'+$(e.currentTarget).attr('code'))

class Hooful.Views.HoofulsMeetWithdrawmeet extends Backbone.View
  template: JST['hoofuls/reopen']
  tagName: 'div'

  events:
    'click li': 'fillForm'

  initialize: ->

  render: ->
    $(@el).html(@template(meet: @options))
    this
  
  fillForm: (event)->
    index = $('#manageMeet .dropdown-menu li').index($(event.target))
    $('.mmTitle').text @options.models[index].get('mTitle')
    $('.hManage').attr("mcode",@options.models[index].get('mCode'))
    winfo = new Hooful.Views.HoofulsMeetWithdrawinfo({
      mhost: $('.hManage').attr "mhost"
      mcode: $('.hManage').attr "mcode"
    })
    $('.mWithdraw').html(winfo.render().el)


class Hooful.Views.HoofulsMeetWithdrawinfo extends Backbone.View
  template: JST['hoofuls/manage_winfo']
  tagName: 'div'

  initialize: (options) ->
    this.mhost = options.mhost
    this.mcode = options.mcode
    @doRender()

  render: ->
    $(@el).html(@template(winfo: @winfo))
    this

  doRender: ->
    @winfo = new Hooful.Collections.ManageWithdrawinfo({},{mHost: this.mhost, mCode: this.mcode})
    @winfo.fetch(success: =>
      @render()
    )
      
class Hooful.Views.HoofulsMeetPrint extends Backbone.View

  template: JST['hoofuls/print']
  tagName: 'div'

  events:
    'click .btnPrint' : 'printing'

  initialize: ->
    _.bindAll(this, 'loadPrint','printing')
    $('.hPrint').click @loadPrint

  render: (target) ->
    target = (if target then target else @el)
    $(target).addClass("modal hide fade").attr("id","meetPrint").html(@template())
    this

  loadPrint: ->
    $('#meetPrint').modal()

  printing: ->
    printIt $('#meetPersonPrint').html()

class Hooful.Views.HoofulsMeetPrintsale extends Backbone.View

  template: JST['hoofuls/print_sales']
  tagName: 'div'

  events:
    'click .btnPrint' : 'printing'

  initialize: ->
    _.bindAll(this, 'loadPrint','printing')
    $('.hPrint').click @loadPrint

  render: (target) ->
    target = (if target then target else @el)
    $(target).addClass("modal hide fade").attr("id","salesPrint").html(@template())
    this

  loadPrint: ->
    $('#salesPrint').modal()

  printing: ->
    printIt $('#meetSalePrint').html()

class Hooful.Views.HoofulsManagePeople extends Backbone.View

  tagName: 'span'
  el: $('body')

  initialize: ->
    this.isNow = 'person'
    this.isType = 'participants'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'changeManage')
    $(".ulink").click @changeManage
    @loadCode()
    @remeet = new Hooful.Collections.ManageWithdrawmeet()
    @remeet.fetch(
      data: {mHost: this.mhost}
      success: =>
        reopen = new Hooful.Views.HoofulsMeetWithdrawmeet(@remeet)
        $('#manageMeet .dropdown-menu').html(reopen.render().el)
        mview = new Hooful.Views.HoofulsMeetViewlink(@remeet)
        $('#manageMeet .meetview').html(mview.render().el)
    )

  render: (target) ->
    this

  loadCode: ->
    manage_code = new Hooful.Views.HoofulsManageCode()
    $('.hManageDetail').html(manage_code.render().el)

  loadPerson: ->
    manage = new Hooful.Views.HoofulsManageMeet()
    $('.hManageDetail').html(manage.render().el)

  loadReserved: ->
    reserved = new Hooful.Views.HoofulsManageReserved()
    $('.hManageDetail').html(reserved.render().el)

  loadService: ->
    service = new Hooful.Views.HoofulsManageService()
    $('.hManageDetail').html(service.render().el)
    review = new Hooful.Views.HoofulsService()

  loadTicket: ->
    manage_ticket = new Hooful.Views.HoofulsManageTicket(
      mcode: this.mcode
    )
    $('.hManageDetail').html(manage_ticket.render().el)

  loadMoney: ->
    money = new Hooful.Views.HoofulsCalendarLarge()
    $('.hManageDetail').html(money.render('','').el)

  loadReport: ->
    manage_report = new Hooful.Views.HoofulsManageReport(
      mcode: this.mcode
    )
    $('.hManageDetail').html(manage_report.render().el)

  changeManage: (e) ->
    $(".ulink").each ->
      $(this).removeClass "current"
    if $(e.currentTarget).attr('type') is "code"
      this.isNow = "code"
      @loadCode()
      $(e.currentTarget).addClass "current"
    else if $(e.currentTarget).attr('type') is "reserved"
      this.isNow = "reserved"
      @loadReserved()
      $(e.currentTarget).addClass "current"
    else if $(e.currentTarget).attr('type') is "person"
      this.isNow = "person"
      @loadPerson()
      $(e.currentTarget).addClass "current"
    else if $(e.currentTarget).attr('type') is "service"
      this.isNow = "service"
      @loadService()
      $(e.currentTarget).addClass "current"
    else if $(e.currentTarget).attr('type') is "ticket"
      this.isNow = "ticket"
      @loadTicket()
      $(e.currentTarget).addClass "current"
    else if $(e.currentTarget).attr('type') is "money"
      this.isNow = "money"
      @loadMoney()
      $(e.currentTarget).addClass "current"
    else if $(e.currentTarget).attr('type') is "report"
      this.isNow = "report"
      @loadReport()
      $(e.currentTarget).addClass "current"

class Hooful.Views.HoofulsManageReserved extends Backbone.View

  template: JST['hoofuls/manage_reserved']
  tagName: 'span'

  initialize: ->
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    this.mstate = '0'
    this.mlist = ''
    this.modalText = ''
    @setCheck = '0'
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'changeManage')
    @doRender()

  events:
    'click .State' : 'changeState0'
    'click .State2' : 'changeState2'
    'click .State3' : 'changeState3'
    'click .State4' : 'changeState4'
    'click .State5' : 'changeState5'
    'click .Use' : 'changeUse'
    'click .btnReserv' : 'changeState'

  render: (target) ->
    $(@el).html(@template(status: @status, mcode: this.mcode))
    this

  doRender: ->
    @render()
    @loadPerson()

  loadPerson: ->
    @ticket = new Hooful.Collections.ManageReservedStateCount()
    @ticket.fetch(
      data: {mCode: this.mcode,mHost: this.mhost}
      type: "GET"
      success: =>
        $('.hmuHeader .snum').text(@ticket.models[0].get('snum'))
        $('.hmuHeader .snum2').text(@ticket.models[0].get('snum2'))
        $('.hmuHeader .snum3').text(@ticket.models[0].get('snum3'))
        $('.hmuHeader .snum4').text(@ticket.models[0].get('snum4'))
        $('.hmuHeader .snum5').text(@ticket.models[0].get('snum5'))
        $('.hmuHeader .snum10').text(@ticket.models[0].get('snum10'))
    )
    manage_person = new Hooful.Views.HoofulsManageReservedState(
      mstate: this.mstate,
      mcode: this.mcode,
      mhost: this.mhost,
      mlist: this.mlist
    )

  changeManage: (e) ->
    $(".ulink").each ->
      $(this).removeClass "current"
    if $(e.currentTarget).attr('type') is "person"
      this.isNow = "person"
      @loadPerson()
    else if $(e.currentTarget).attr('type') is "ticket"
      this.isNow = "ticket"
      @loadTicket()
    else if $(e.currentTarget).attr('type') is "report"
      this.isNow = "report"
      @loadReport()
    
  changeState0: ->
    this.mstate = '0'
    @loadPerson()
  changeState2: ->
    this.mstate = '2'
    @loadPerson()
  changeState3: ->
    this.mstate = '3'
    @loadPerson()
  changeState4: ->
    this.mstate = '4'
    @loadPerson()
  changeState5: ->
    this.mstate = '5'
    @loadPerson()
  changeUse: ->
    this.mstate = '10'
    @loadPerson()

  changeState: (e) ->
    @status = new Hooful.Collections.changeTicketState()
    @status.fetch(
      data: {
        tCode: $(e.currentTarget).attr("code"),
        tState: $(e.currentTarget).attr("state")
      }
      type: "GET"
      success: =>
        if $(e.currentTarget).attr("state") is "3"
          alertView("예약 불가처리가 완료되었습니다.")
        else if $(e.currentTarget).attr("state") is "5"
          alertView("예약승인이 완료되었습니다.")
        @loadPerson()
    )

class Hooful.Views.HoofulsManageService extends Backbone.View

  template: JST['hoofuls/manage_service']
  tagName: 'span'

  events:
    'click .hmsMenu .faq' : 'changeMenu'

  initialize: ->
    this.isNow = 'person'
    this.isType = 'participants'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    this.order = 'name'
    this.sort = 'desc'
    this.iskeyword = ''
    @setCheck = '0'
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this)

  render: (target) ->
    $(@el).html(@template(status: @status, mcode: this.mcode))
    this

  changeMenu: ->
    service = new Hooful.Views.HoofulsManageServiceFAQ()
    $('.hManageDetail').html(service.render().el)

class Hooful.Views.HoofulsManageServiceFAQ extends Backbone.View

  template: JST['hoofuls/manage_service_faq']
  tagName: 'span'

  events:
    'click .hmsMenu .service' : 'changeMenu'

  initialize: ->
    this.isNow = 'person'
    this.isType = 'participants'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    this.order = 'name'
    this.sort = 'desc'
    this.iskeyword = ''
    @setCheck = '0'
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this)

  render: (target) ->
    $(@el).html(@template(status: @status, mcode: this.mcode))
    this

  changeMenu: ->
    service = new Hooful.Views.HoofulsManageService()
    $('.hManageDetail').html(service.render().el)
    review = new Hooful.Views.HoofulsService()

class Hooful.Views.HoofulsManageWithdraw extends Backbone.View

  tagName: 'span'
  el: $('body')

  initialize: ->
    this.isNow = 'person'
    this.isType = 'participants'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'setWithdraw')
    $(".btnWithdrawBig").click @setWithdraw
    @loadTicket()
    @loadWithdraw()

  render: (target) ->
    this

  loadTicket: ->
    manage_sale = new Hooful.Views.HoofulsManageTicketsalewithdraw(
      type: this.isType,
      mcode: this.mcode,
      mhost: this.mhost,
      order: this.order,
      sort: this.sort,
      keyword: this.iskeyword
    )

  loadWithdraw: ->
    manage_sale = new Hooful.Views.HoofulsManageWithdrawlist(
      mUserid: this.mUserid
    )

  setWithdraw: ->
    unless $('#txtBank').val()
      alert "은행을 입력해 주세요."
      return
    unless $('#txtHolder').val()
      alert "예금주를 입력해 주세요."
      return
    unless $('#txtAccount').val()
      alert "계좌번호를 입력해 주세요."
      return
    if confirm("========================\n\n은      행 : "+$('#txtBank').val()+"\n예 금 주 : "+$('#txtHolder').val()+"\n계좌번호 : "+$('#txtAccount').val()+"\n\n========================\n\n이 정보로 출금신청을 하시겠습니까?")
      @sales = new Hooful.Collections.ManageWithdrawSet()
      @sales.fetch(
        data: {
          mBank: $('#txtBank').val(),
          mHolder: $('#txtHolder').val(),
          mAccount: $('#txtAccount').val(),
          mUserid: $('.hManage').attr('mHost'),
          mCode: '',
          mPrice: $('.hManage').attr('mRefund')
        }
        type: "POST"
        success: =>
          @with = new Hooful.Collections.ManageWithdrawCalcurate()
          @with.fetch(
            data: {
              mcode: this.mcode,
              mhost: this.mhost,
              wid: @sales.models[0].get('_id')
            }
          type: "GET"
          success: =>
            alert "정산신청끝"
          )
          alert @sales.models[0].get('mHolder')
      )

class Hooful.Views.HoofulsManagePerson extends Backbone.View

  template: JST['hoofuls/manage_person']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.order = @options.order
    this.sort = @options.sort
    this.keyword = @options.keyword
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @person = new Hooful.Collections.Ticketsale()
    @person.fetch(
      data: {type: this.isType, mCode: this.mcode, mHost: this.mhost, order: this.order, sort: this.sort, keyword: this.keyword}
      type: "GET"
      success: =>
        $('.hPerson').html(@template(person: @person, S3ADDR: @S3ADDR))
    )
    #@person = new Hooful.Collections.Managemeet({},{type: this.isType, mcode: this.mcode, mhost: this.mhost, order: #this.order, sort: this.sort, keyword: this.keyword})
    #@person.fetch(success: =>
    #  $('.hPerson').html(@template(person: @person, S3ADDR: @S3ADDR))
    #)
    #$('.hPerson').html(@template)
    if this.isType is "participants"
      $(".hdmParticipants").addClass "set"
      $(".hdmWaittings").removeClass "set"
    else
      $(".hdmWaittings").addClass "set"
      $(".hdmParticipants").removeClass "set"
    

class Hooful.Views.HoofulsManageReservedState extends Backbone.View

  template: JST['hoofuls/manage_reserved_ticket']
  el: $('body')

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.mstate = @options.mstate
    this.mlist = @options.mlist
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @ticket = new Hooful.Collections.ManageReservedState()
    @ticket.fetch(
      data: {mState: this.mstate,mCode: this.mcode,mHost: this.mhost,mList: this.mlist}
      type: "GET"
      success: =>
        $('.hTicket').html(@template(ticket: @ticket, S3ADDR: @S3ADDR))
    )
    if this.mstate is "0"
      $(".State").addClass "set"
      $(".State2").removeClass "set"
      $(".State3").removeClass "set"
      $(".State4").removeClass "set"
      $(".State5").removeClass "set"
      $(".Use").removeClass "set"
    else if this.mstate is "2"
      $(".State").removeClass "set"
      $(".State2").addClass "set"
      $(".State3").removeClass "set"
      $(".State4").removeClass "set"
      $(".State5").removeClass "set"
      $(".Use").removeClass "set"
    else if this.mstate is "3"
      $(".State").removeClass "set"
      $(".State3").addClass "set"
      $(".State2").removeClass "set"
      $(".State4").removeClass "set"
      $(".State5").removeClass "set"
      $(".Use").removeClass "set"
    else if this.mstate is "4"
      $(".State").removeClass "set"
      $(".State4").addClass "set"
      $(".State2").removeClass "set"
      $(".State3").removeClass "set"
      $(".State5").removeClass "set"
      $(".Use").removeClass "set"
    else if this.mstate is "5"
      $(".State").removeClass "set"
      $(".State5").addClass "set"
      $(".State2").removeClass "set"
      $(".State3").removeClass "set"
      $(".State4").removeClass "set"
      $(".Use").removeClass "set"
    else
      $(".State").removeClass "set"
      $(".Use").addClass "set"
      $(".State2").removeClass "set"
      $(".State3").removeClass "set"
      $(".State4").removeClass "set"
      $(".State5").removeClass "set"

class Hooful.Views.HoofulsManageReservedStatePre extends Backbone.View

  template: JST['hoofuls/manage_reserved_ticket_pre']
  el: $('body')

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.mstate = @options.mstate
    this.mlist = @options.mlist
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @ticket = new Hooful.Collections.ManageReservedState()
    @ticket.fetch(
      data: {mState: this.mstate,mCode: this.mcode,mHost: this.mhost,mList: this.mlist}
      type: "GET"
      success: =>
        $('.hTicket').html(@template(ticket: @ticket, S3ADDR: @S3ADDR))
    )

class Hooful.Views.HoofulsManageReport extends Backbone.View

  template: JST['hoofuls/manage_report']
  tagName: 'div'

  initialize: ->
    this.isNow = 'report'
    this.isType = 'activity'
    this.mcode = $(".hManage").attr "mCode"
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'changeActivity', 'changePerson', 'changeTicket')
    @doRender()

  events:
    'click .hdmActivity' : 'changeActivity'
    'click .hdmPerson' : 'changePerson'
    'click .hdmTicket' : 'changeTicket'
  
  render: ->
    $(@el).html(@template())
    this

  doRender: ->
    @render()
    @loadActivity()
  
  loadActivity: ->
    reportActivity = new Hooful.Views.HoofulsReportactivity(
      type: this.isType,
      mcode: this.mcode
    )
  
  loadPerson: ->
    reportActivity = new Hooful.Views.HoofulsReportperson(
      type: this.isType,
      mcode: this.mcode
    )
  
  loadTicket: ->
    reportActivity = new Hooful.Views.HoofulsReportticket(
      type: this.isType,
      mcode: this.mcode
    )

  changeActivity: ->
    this.isType = 'activity'
    @loadActivity()

  changePerson: ->
    this.isType = 'person'
    @loadPerson()

  changeTicket: ->
    this.isType = 'ticket'
    @loadTicket()
    

class Hooful.Views.HoofulsManageCode extends Backbone.View

  template: JST['hoofuls/manage_code']
  tagName: 'div'

  events:
    'keyup #saleSearch' : 'keySearch'
    'click .btnSearchCode' : 'searchCode'
    'click .btnReserv' : 'changeState'

  initialize: ->
    this.isType = 'ticket'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    this.mccode = $('#mcCode').val()
    this.mstate = '2'
    this.mlist = ''
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @doRender()

  render: ->
    $(@el).html(@template(status: @status, mcode: this.mcode))
    $('.hManageCodeLine').css('height',($('#hContainer').height()-336)+'px')
    this

  doRender: ->
    @status = new Hooful.Collections.Managecnt({},{type: this.isType, mcode: this.mcode, mhost: this.mhost})
    @status.fetch(success: =>
      @render()
      @loadReserved()
    )

  loadTickets: ->
    manage_ticket = new Hooful.Views.HoofulsManageCodeTicket(
      type: this.isType,
      mcode: this.mcode,
      mhost: this.mhost,
      mccode: this.mccode
    )
    $('.mcTicketArea').html(manage_ticket.render().el)

  searchCode: ->
    unless $('#mcCode').val()
      alert "티켓코드를 입력해 주세요."
      $('#mcCode').focus()
    else
      this.mccode = $('#mcCode').val()
      @loadTickets()

  loadReserved: ->
    manage_person = new Hooful.Views.HoofulsManageReservedStatePre(
      mstate: this.mstate,
      mcode: this.mcode,
      mhost: this.mhost,
      mlist: this.mlist
    )

  changeState: (e) ->
    @status = new Hooful.Collections.changeTicketState()
    @status.fetch(
      data: {
        tCode: $(e.currentTarget).attr("code"),
        tState: $(e.currentTarget).attr("state")
      }
      type: "GET"
      success: =>
        if $(e.currentTarget).attr("state") is "3"
          alertView("예약 불가처리가 완료되었습니다.")
        else if $(e.currentTarget).attr("state") is "5"
          alertView("예약승인이 완료되었습니다.")
        @loadReserved()
    )

class Hooful.Views.HoofulsManageCodeTicket extends Backbone.View

  template: JST['hoofuls/manage_codeticket']

  events:
    'click .btnTicket' : 'useTicket'

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.mccode = @options.mccode
    this.status = "0"
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    $(@el).html(@template(tickets: @ticket, S3ADDR: @S3ADDR, status: this.status))
    this.status = "1"
    this

  loadResult: ->
    @ticket = new Hooful.Collections.ManageCodeTicket()
    @ticket.fetch(
      data: {mCode: this.mcode,mHost: this.mhost,mcCode: this.mccode}
      type: "GET"
      success: =>
        @render()
    )

  useTicket: (e) ->
    @btnUse = $(e.currentTarget)
    @tUse = new Hooful.Collections.ManageCodeUse()
    @tUse.fetch(
      data: {tCode: $(e.currentTarget).parent().attr("code"), state: $(e.currentTarget).attr("state")}
      type: "GET"
      success: =>
        if @tUse.models[0].get('tUse') is 1
          alert "티켓이 사용되었습니다.\n확인은 인원관리에서 가능합니다."
        btnTxt = if (@tUse.models[0].get('tUse') is 1) then "사용 취소" else "사용승인"
        $(@btnUse).attr("state",@tUse.models[0].get('tUse')).text(btnTxt)
    )

class Hooful.Views.HoofulsManageTicket extends Backbone.View

  template: JST['hoofuls/manage_ticket']
  tagName: 'div'

  events:
    'keyup #saleSearch' : 'keySearch'

  initialize: ->
    this.isType = 'ticket'
    this.mcode = $(".hManage").attr "mCode"
    this.mhost = $(".hManage").attr "mHost"
    this.order = 'name'
    this.sort = 'desc'
    this.iskeyword = ''
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @doRender()

  render: ->
    $(@el).html(@template(status: @status, mcode: this.mcode))
    this

  doRender: ->
    @status = new Hooful.Collections.Managecnt({},{type: this.isType, mcode: this.mcode, mhost: this.mhost})
    @status.fetch(success: =>
      @render()
      @loadTickets()
    )

  loadTickets: ->
    manage_ticket = new Hooful.Views.HoofulsManageTicketlist(
      type: this.isType,
      mcode: this.mcode,
      mhost: this.mhost,
      order: this.order,
      sort: this.sort
    )
    manage_sale = new Hooful.Views.HoofulsManageTicketsale(
      type: this.isType,
      mcode: this.mcode,
      mhost: this.mhost,
      order: this.order,
      sort: this.sort,
      keyword: this.iskeyword
    )
    print = new Hooful.Views.HoofulsMeetPrintsale()
    $('body').append(print.render().el)

  loadSales: ->
    manage_sale = new Hooful.Views.HoofulsManageTicketsale(
      type: this.isType,
      mcode: this.mcode,
      mhost: this.mhost,
      order: this.order,
      sort: this.sort,
      keyword: this.iskeyword
    )

  keySearch: (e) ->
    this.iskeyword= $('#saleSearch').val()
    @loadSales()

class Hooful.Views.HoofulsManageTicketlist extends Backbone.View

  template: JST['hoofuls/manage_ticketlist']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.order = @options.order
    this.sort = @options.sort
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @ticket = new Hooful.Collections.Tickets()
    @ticket.fetch(
      data: {mCode: this.mcode,mHost: this.mhost}
      type: "GET"
      success: =>
         $('.hTicket').html(@template(tickets: @ticket, S3ADDR: @S3ADDR))
    )


class Hooful.Views.HoofulsManageTicketsale extends Backbone.View

  template: JST['hoofuls/manage_ticketsale']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.order = @options.order
    this.sort = @options.sort
    this.keyword = @options.keyword
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @sales = new Hooful.Collections.Ticketsale()
    @sales.fetch(
      data: {mCode: this.mcode,mHost: this.mhost, keyword: this.keyword}
      type: "GET"
      success: =>
        $('.hSales').html(@template(sales: @sales, S3ADDR: @S3ADDR))
    )

class Hooful.Views.HoofulsManageTicketsalewithdraw extends Backbone.View

  template: JST['hoofuls/manage_ticketsale']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    this.mhost = @options.mhost
    this.order = @options.order
    this.sort = @options.sort
    this.keyword = @options.keyword
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @sales = new Hooful.Collections.Ticketsalewithdraw()
    @sales.fetch(
      data: {mCode: this.mcode,mHost: this.mhost, keyword: this.keyword}
      type: "GET"
      success: =>
        $('.hSales').html(@template(sales: @sales, S3ADDR: @S3ADDR))
    )

class Hooful.Views.HoofulsManageWithdrawlist extends Backbone.View

  template: JST['hoofuls/manage_withdraw']

  initialize: ->
    this.mUserid = @options.mUserid
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @sales = new Hooful.Collections.ManageWithdraw()
    @sales.fetch(
      data: {mUserid: this.mUserid}
      type: "GET"
      success: =>
        $('.hRefunds').html(@template(sales: @sales, S3ADDR: @S3ADDR))
    )

class Hooful.Views.HoofulsReportactivity extends Backbone.View

  template: JST['hoofuls/report_activity']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @person = new Hooful.Collections.Reportcnt({},{type: this.isType, mcode: this.mcode})
    @person.fetch(success: =>
      $('.reportResult').html(@template(person: @person, S3ADDR: @S3ADDR))
      @drawChart()
    )
    if this.isType is "activity"
      $(".hdmActivity").addClass "set"
      $(".hdmPerson").removeClass "set"
      $(".hdmTicket").removeClass "set"
    else if this.isType is "person"
      $(".hdmPerson").addClass "set"
      $(".hdmActivity").removeClass "set"
      $(".hdmTicket").removeClass "set"
    else
      $(".hdmTicket").addClass "set"
      $(".hdmActivity").removeClass "set"
      $(".hdmPerson").removeClass "set"
    
  drawChart: ->
     data =
        sin: []
        cos: []
      i = 0

      while i < 14
        data.sin.push [i, Math.sin(i)]
        data.cos.push [i, Math.cos(i)]
        i += 0.5
      
      $.plot $("#chart"), [
        label: "Sin"
        data: data.sin
        lines:
          fillColor: "#da4c4c"
        points:
          fillColor: "#fff"
      ,
        label: "Cos"
        data: data.cos
        lines:
          fillColor: "#444"
        points:
          fillColor: "#fff"
      ],
        grid:
          show: true
          aboveData: true
          color: "#37a6cd"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor:"#37a6cd"
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 20
          backgroundColor : "#fff"
        series:
          grow:
            active: false
          lines:
            show: true
            fill: false
            lineWidth: 4
            steps: false
          points:
            show: true
            radius: 5
            symbol: "circle"
            fill: true
            borderColor: "#fff"
        legend:
          position: "se"
        color: "#37a6cd"
        shadowSize: 1
        tolltip: true
        tolltipOpts:
          content: "%s : %y.3"
          shifts:
            x: -30
            y: -50
          defaultTheme: false


class Hooful.Views.HoofulsReportperson extends Backbone.View

  template: JST['hoofuls/report_person']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @person = new Hooful.Collections.Managemeet({},{type: this.isType, mcode: this.mcode})
    @person.fetch(success: =>
      $('.reportResult').html(@template(person: @person, S3ADDR: @S3ADDR))
      @drawChart()
    )
    if this.isType is "activity"
      $(".hdmActivity").addClass "set"
      $(".hdmPerson").removeClass "set"
      $(".hdmTicket").removeClass "set"
    else if this.isType is "person"
      $(".hdmPerson").addClass "set"
      $(".hdmActivity").removeClass "set"
      $(".hdmTicket").removeClass "set"
    else
      $(".hdmTicket").addClass "set"
      $(".hdmActivity").removeClass "set"
      $(".hdmPerson").removeClass "set"
    
  drawChart: ->
      datasets =
      usa:
        label: "USA"
        data: [[1988, 483994], [1989, 479060], [1990, 457648], [1991, 401949], [1992, 424705], [1993, 402375], [1994, 377867], [1995, 357382], [1996, 337946], [1997, 336185], [1998, 328611], [1999, 329421], [2000, 342172], [2001, 344932], [2002, 387303], [2003, 440813], [2004, 480451], [2005, 504638], [2006, 528692]]

      russia:
        label: "Russia"
        data: [[1988, 218000], [1989, 203000], [1990, 171000], [1992, 42500], [1993, 37600], [1994, 36600], [1995, 21700], [1996, 19200], [1997, 21300], [1998, 13600], [1999, 14000], [2000, 19100], [2001, 21300], [2002, 23600], [2003, 25100], [2004, 26100], [2005, 31100], [2006, 34700]]

      uk:
        label: "UK"
        data: [[1988, 62982], [1989, 62027], [1990, 60696], [1991, 62348], [1992, 58560], [1993, 56393], [1994, 54579], [1995, 50818], [1996, 50554], [1997, 48276], [1998, 47691], [1999, 47529], [2000, 47778], [2001, 48760], [2002, 50949], [2003, 57452], [2004, 60234], [2005, 60076], [2006, 59213]]

      germany:
        label: "Germany"
        data: [[1988, 55627], [1989, 55475], [1990, 58464], [1991, 55134], [1992, 52436], [1993, 47139], [1994, 43962], [1995, 43238], [1996, 42395], [1997, 40854], [1998, 40993], [1999, 41822], [2000, 41147], [2001, 40474], [2002, 40604], [2003, 40044], [2004, 38816], [2005, 38060], [2006, 36984]]

      denmark:
        label: "Denmark"
        data: [[1988, 3813], [1989, 3719], [1990, 3722], [1991, 3789], [1992, 3720], [1993, 3730], [1994, 3636], [1995, 3598], [1996, 3610], [1997, 3655], [1998, 3695], [1999, 3673], [2000, 3553], [2001, 3774], [2002, 3728], [2003, 3618], [2004, 3638], [2005, 3467], [2006, 3770]]

      sweden:
        label: "Sweden"
        data: [[1988, 6402], [1989, 6474], [1990, 6605], [1991, 6209], [1992, 6035], [1993, 6020], [1994, 6000], [1995, 6018], [1996, 3958], [1997, 5780], [1998, 5954], [1999, 6178], [2000, 6411], [2001, 5993], [2002, 5833], [2003, 5791], [2004, 5450], [2005, 5521], [2006, 5271]]

      norway:
        label: "Norway"
        data: [[1988, 4382], [1989, 4498], [1990, 4535], [1991, 4398], [1992, 4766], [1993, 4441], [1994, 4670], [1995, 4217], [1996, 4275], [1997, 4203], [1998, 4482], [1999, 4506], [2000, 4358], [2001, 4385], [2002, 5269], [2003, 5066], [2004, 5194], [2005, 4887], [2006, 4891]]
    
      data = [
        label: "USA"
        data: 38
      ,
        label: "Brazil"
        data: 23
      ,
        label: "India"
        data: 15
      ,
        label: "Turkey"
        data: 9
      ,
        label: "France"
        data: 7
      ,
        label: "China"
        data: 5
      ,
        label: "Germany"
        data: 3
      ]
      
      $.plot $("#chart"), data,
        grid:
          show: true
          aboveData: true
          color: "#37a6cd"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor:"#37a6cd"
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 20
          backgroundColor : "#fff"
        series:
          grow:
            active: false
          pie:
            show: true
            innerRadius: 0.4
            highlight:
              opacity: 0.1
            radius: 1
            stroke:
              color: "#fff"
              width: 2
            startAngle: 2
            combine:
              color: "#EEE"
              threshold: 0.05
            label:
              show: true
              radius: 1
              formatter: (label, series) ->
                "<div class=\"label label-inverse\">" + label + "&nbsp;" + Math.round(series.percent) + "%</div>"
        legend:
          position: "se"
        color: "#37a6cd"
        shadowSize: 1
        tolltip: true
        tolltipOpts:
          content: "%s : %y.3"
          shifts:
            x: -30
            y: -50
          defaultTheme: false


class Hooful.Views.HoofulsReportticket extends Backbone.View

  template: JST['hoofuls/report_ticket']

  initialize: ->
    this.isType = @options.type
    this.mcode = @options.mcode
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    @loadResult()

  render: ->
    this

  loadResult: ->
    @person = new Hooful.Collections.Managemeet({},{type: this.isType, mcode: this.mcode})
    @person.fetch(success: =>
      $('.reportResult').html(@template(person: @person, S3ADDR: @S3ADDR))
      @drawChart()
    )
    if this.isType is "activity"
      $(".hdmActivity").addClass "set"
      $(".hdmPerson").removeClass "set"
      $(".hdmTicket").removeClass "set"
    else if this.isType is "person"
      $(".hdmPerson").addClass "set"
      $(".hdmActivity").removeClass "set"
      $(".hdmTicket").removeClass "set"
    else
      $(".hdmTicket").addClass "set"
      $(".hdmActivity").removeClass "set"
      $(".hdmPerson").removeClass "set"
    
  drawChart: ->
      datasets =
      usa:
        label: "USA"
        data: [[1988, 483994], [1989, 479060], [1990, 457648], [1991, 401949], [1992, 424705], [1993, 402375], [1994, 377867], [1995, 357382], [1996, 337946], [1997, 336185], [1998, 328611], [1999, 329421], [2000, 342172], [2001, 344932], [2002, 387303], [2003, 440813], [2004, 480451], [2005, 504638], [2006, 528692]]

      russia:
        label: "Russia"
        data: [[1988, 218000], [1989, 203000], [1990, 171000], [1992, 42500], [1993, 37600], [1994, 36600], [1995, 21700], [1996, 19200], [1997, 21300], [1998, 13600], [1999, 14000], [2000, 19100], [2001, 21300], [2002, 23600], [2003, 25100], [2004, 26100], [2005, 31100], [2006, 34700]]

      uk:
        label: "UK"
        data: [[1988, 62982], [1989, 62027], [1990, 60696], [1991, 62348], [1992, 58560], [1993, 56393], [1994, 54579], [1995, 50818], [1996, 50554], [1997, 48276], [1998, 47691], [1999, 47529], [2000, 47778], [2001, 48760], [2002, 50949], [2003, 57452], [2004, 60234], [2005, 60076], [2006, 59213]]

      germany:
        label: "Germany"
        data: [[1988, 55627], [1989, 55475], [1990, 58464], [1991, 55134], [1992, 52436], [1993, 47139], [1994, 43962], [1995, 43238], [1996, 42395], [1997, 40854], [1998, 40993], [1999, 41822], [2000, 41147], [2001, 40474], [2002, 40604], [2003, 40044], [2004, 38816], [2005, 38060], [2006, 36984]]

      denmark:
        label: "Denmark"
        data: [[1988, 3813], [1989, 3719], [1990, 3722], [1991, 3789], [1992, 3720], [1993, 3730], [1994, 3636], [1995, 3598], [1996, 3610], [1997, 3655], [1998, 3695], [1999, 3673], [2000, 3553], [2001, 3774], [2002, 3728], [2003, 3618], [2004, 3638], [2005, 3467], [2006, 3770]]

      sweden:
        label: "Sweden"
        data: [[1988, 6402], [1989, 6474], [1990, 6605], [1991, 6209], [1992, 6035], [1993, 6020], [1994, 6000], [1995, 6018], [1996, 3958], [1997, 5780], [1998, 5954], [1999, 6178], [2000, 6411], [2001, 5993], [2002, 5833], [2003, 5791], [2004, 5450], [2005, 5521], [2006, 5271]]

      norway:
        label: "Norway"
        data: [[1988, 4382], [1989, 4498], [1990, 4535], [1991, 4398], [1992, 4766], [1993, 4441], [1994, 4670], [1995, 4217], [1996, 4275], [1997, 4203], [1998, 4482], [1999, 4506], [2000, 4358], [2001, 4385], [2002, 5269], [2003, 5066], [2004, 5194], [2005, 4887], [2006, 4891]]
    
      data =
        sin: []
        cos: []
      i = 0

      while i < 14
        data.sin.push [i, Math.sin(i)]
        data.cos.push [i, Math.cos(i)]
        i += 0.5
      
      $.plot $("#chart"), [
        label: "Sin"
        data: data.sin
        lines:
          fillColor: "#DA4C4C"
        points:
          fillColor: "#fff"
      ,
        label: "Cos"
        data: data.cos
        lines:
          fillColor: "#444"
        points:
          fillColor: "#fff"
      ],
        yaxis:
          min: 0

        xaxis:
          tickDecimals: 0
       

