class Hooful.Views.HoofulsUsermeet extends Backbone.View
  template: JST['hoofuls/meet']
  tagName: 'span'
  el: $("body")

  initialize: ->
    this.count = 1
    this.isLoading = false
    this.type = 'participated'
    this.userid = $('#hUserinfo').attr('userid')
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'checkScroll', 'changeMore', 'changeOrder')
    
    $('.ulink').click(this.changeOrder);
    $('#hMore').click(this.changeMore);

  render: ->
    this.loadResult()
    this

  events:
    'click .clink' : 'orderChange'

  loadResult: ->
    this.isLoading = true
    @meet = new Hooful.Collections.Usermeets({},{type: this.type, userid: this.userid, page: this.count})
    @meet.fetch(success: =>
      this.isLoading = false
      $('#hMoim').addClass('list').append(@template(meet: @meet, S3ADDR: @S3ADDR))
    )

  loadChange: ->
    this.isLoading = true
    @meet = new Hooful.Collections.Usermeets({},{type: this.type, userid: this.userid, page: this.count})
    @meet.fetch(success: =>
      this.isLoading = false
      $('#hMoim').addClass('list').html(@template(meet: @meet, S3ADDR: @S3ADDR))
    )

  checkScroll: ->
    triggerPoint = 500
    if  !this.isLoading and $('body').scrollTop() + $('body').height() + triggerPoint > $('body')[0].scrollHeight
      this.count += 1
      this.loadResult()

  changeMore: ->
    this.count += 1
    this.loadResult()

  changeOrder: (e) ->
    if this.isLoading is false
      this.count = 1
      this.type = $(e.currentTarget).attr('type')
      if this.type is "guestbook"
        $('#hMore').hide()
        this.loadGuestbook()
      else
        $('#hMore').show()
        this.loadChange()
      $(".ulink").each ->
        $(this).removeClass "current"
      $(e.currentTarget).addClass "current"
    else
      if this.type is "guestbook"
        alert "방명록을 불러오는 중입니다."
      else
        alert "활동을 불러오는 중입니다."

  loadGuestbook: ->
    this.isLoading = true
    guestbook_wrap = new Hooful.Views.HoofulsGuestbookWrap()
    $('#hMoim').addClass('list').html(guestbook_wrap.render().el)
    this.isLoading = false
