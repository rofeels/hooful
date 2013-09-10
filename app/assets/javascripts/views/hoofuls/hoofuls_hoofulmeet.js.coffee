class Hooful.Views.HoofulsHoofulmeet extends Backbone.View
  template: JST['hoofuls/meet']
  tagName: 'span'
  el: $("body")

  initialize: (options) ->
    this.count = 1
    this.isLoading = false
    this.isOrder = 'date'
    this.isKeyword = options.keyword
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'checkScroll', 'changeMore', 'changeOrder','meetLike','meetLikeIcon')
    #$(window).scroll(this.checkScroll);
    $('.clink').click(this.changeOrder);
    $('#hMore').click(this.changeMore);
  render: ->
    this.loadResult()
    this

  events:
    'click .clink' : 'orderChange'
    'click .meet-like' : 'meetLike'

  loadResult: ->
    this.isLoading = true
    @meet = new Hooful.Collections.Hoofulmeets({},{page: this.count, order: this.isOrder, keyword: this.isKeyword})
    @meet.fetch(success: =>
      if this.isKeyword
        $('.mcnt').text '('+@meet.models.length+')'
        if @meet.models.length is 0
          $('.navmeet').hide()
      this.isLoading = false

      $('#hMoim').addClass('list').append(@template(meet: @meet, S3ADDR: @S3ADDR))
      $("#hMore").hide() if @meet.length < 28
      $('#hEmpty').hide() if @meet.models.length > 0
      $('.meet-like-icon').click(this.meetLikeIcon)
      $('.meet-like').click(this.meetLike)
      $('.hCard').hover( (e) ->
        $(this).children(".cInfo").show()
        hoo = new Hooful.Collections.HooChkCode()
        hoo.fetch(
          async: false
          data: {
            mCode: $(this).attr('code'),
            mUserid: $('#hContainer').attr('mHost')
          }
          type: "POST"
          success: =>
            if hoo.models[0].get('user') > 0
              $(this).children(".cInfo").children("div.hoo").children("i.hoo").addClass "set"
            else
              $(this).children(".cInfo").children("div.hoo").children("i.hoo").removeClass "set"
            $(this).children(".cInfo").children("div.hoo").children(".meet-like").text hoo.models[0].get('count')
        )
      , (e) ->
        $(this).children(".cInfo").hide()
      )
    )

  loadChange: ->
    this.isLoading = true
    @meet = new Hooful.Collections.Hoofulmeets({},{page: this.count, order: this.isOrder, keyword: this.isKeyword})
    @meet.fetch(success: =>
      this.isLoading = false
      $('#hMoim').addClass('list').html(@template(meet: @meet, S3ADDR: @S3ADDR))
      $("#hMore").hide() if @meet.length < 28
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
    this.count = 1
    this.isOrder = $(e.currentTarget).attr('order')
    this.loadChange()

  meetLike: (e) ->
    unless $('#hContainer').attr('mHost')
      alert '로그인이 필요합니다.'
      return false
    if $(e.target).hasClass('set')
      @hoolike = new Hooful.Collections.HooDelLike()
      @hoolike.fetch(
        data: {
          mUrl: '',
          mCode: $(e.target).attr('code'),
          mHost: "",
          mUserid: $('#hContainer').attr('mHost')
        }
        type: "POST"
        success: =>
          $(e.target).text @hoolike.models[0].get('count')
          $(e.target).removeClass('set')
      )
    else
      @hoolike = new Hooful.Collections.HooAddLike()
      @hoolike.fetch(
        data: {
          mUrl: '',
          mCode: $(e.target).attr('code'),
          mHost: "",
          mUserid: $('#hContainer').attr('mHost')
        }
        type: "POST"
        success: =>
          $(e.target).text @hoolike.models[0].get('count')
          $(e.target).addClass('set')
      )

  meetLikeIcon: (e) ->
    unless $('#hContainer').attr('mHost')
      alert '로그인이 필요합니다.'
      return false
    if $(e.target).hasClass('set')
      @hoolike = new Hooful.Collections.HooDelLike()
      @hoolike.fetch(
        data: {
          mUrl: '',
          mCode: $(e.target).attr('code'),
          mHost: "",
          mUserid: $('#hContainer').attr('mHost')
        }
        type: "POST"
        success: =>
          $(e.target).text @hoolike.models[0].get('count')
          $(e.target).parent().children('.meet-like').text @hoolike.models[0].get('count')
          $(e.target).removeClass('set')
      )
    else
      @hoolike = new Hooful.Collections.HooAddLike()
      @hoolike.fetch(
        data: {
          mUrl: '',
          mCode: $(e.target).attr('code'),
          mHost: "",
          mUserid: $('#hContainer').attr('mHost')
        }
        type: "POST"
        success: =>
          $(e.target).text @hoolike.models[0].get('count')
          $(e.target).parent().children('.meet-like').text @hoolike.models[0].get('count')
          $(e.target).addClass('set')
      )

class Hooful.Views.HoofulsHoofulperson extends Backbone.View
  template: JST['hoofuls/person']
  tagName: 'span'
  el: $("body")

  initialize: (options) ->
    this.count = 1
    this.isLoading = false
    this.isOrder = 'date'
    this.isKeyword = options.keyword
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'checkScroll', 'changeMore', 'changeOrder')
    #$(window).scroll(this.checkScroll);
    $('.clink').click(this.changeOrder);
    $('#hMore').click(this.changeMore);
    
  render: ->
    this.loadResult()
    this

  events:
    'click .clink' : 'orderChange'

  loadResult: ->
    this.isLoading = true
    @person = new Hooful.Collections.Hoofulpersons({},{page: this.count, order: this.isOrder, keyword: this.isKeyword})
    @person.fetch(success: =>
      if this.isKeyword
        $('.pcnt').text '('+@person.models[@person.models.length-1].get('count')+')'
      this.isLoading = false
      $('#hPerson').addClass('list').append(@template(person: @person, S3ADDR: @S3ADDR))
      $("#hMore").hide() if @person.length < 10
      $('#hEmpty').hide() if @person.models.length > 0
      $('#hPerson').show() if @person.models.length > 0
    )

  loadChange: ->
    this.isLoading = true
    @person = new Hooful.Collections.Hoofulpersons({},{page: this.count, order: this.isOrder, keyword: this.isKeyword})
    @person.fetch(success: =>
      this.isLoading = false
      $('#hPerson').addClass('list').html(@template(person: @person, S3ADDR: @S3ADDR))
      $("#hMore").hide() if @meet.length < 10
    )

  checkScroll: ->
    triggerPoint = 500
    if  !this.isLoading and $('body').scrollTop() + $('body').height() + triggerPoint > $('body')[0].scrollHeight
      this.count += 1
      this.loadResult()

  changeMore: ->
    if this.isLoading is false
      this.count += 1
      this.loadResult()
    else
      alert "검색결과를 불러오는 중입니다."

  changeOrder: (e) ->
    this.count = 1
    this.isOrder = $(e.currentTarget).attr('order')
    if this.isOrder is "meet"
      $('#hMoim').show()
      $('#hPerson').hide()
    else
      $('#hMoim').hide()
      $('#hPerson').show()

class Hooful.Views.HoofulsCommunitymeet extends Backbone.View
  template: JST['hoofuls/meet']
  tagName: 'span'
  el: $("body")

  initialize: (options) ->
    this.count = 1
    this.limit = 2
    this.isLoading = false
    this.isOrder = 'date'
    this.isKeyword = options.keyword
    this.isCategory = options.category
    @S3ADDR = "http://d3o755op057jl1.cloudfront.net/"
    _.bindAll(this, 'checkScroll', 'changeMore')
    #$(window).scroll(this.checkScroll);
    $('#hMore').click(this.changeMore);
    
  render: ->
    this.loadResult()
    this

  events:
    'click .clink' : 'orderChange'

  loadResult: ->
    this.isLoading = true
    @meet = new Hooful.Collections.Communitymeets({},{category: this.isCategory, limit: this.limit, page: this.count, order: this.isOrder, keyword: this.isKeyword})
    @meet.fetch(success: =>
      this.isLoading = false
      $('.hcMeet').removeAttr("style")
      $('.hcMeetList').addClass('list').append(@template(meet: @meet, S3ADDR: @S3ADDR))
      $("#hMore").hide() if @meet.length < this.limit
      $('.hcTalk').height($('.hcMeet').height()) if $('.hcTalk').height() < $('.hcMeet').height()
    )

  checkScroll: ->
    triggerPoint = 500
    if  !this.isLoading and $('body').scrollTop() + $('body').height() + triggerPoint > $('body')[0].scrollHeight
      this.count += 1
      this.loadResult()

  changeMore: ->
    this.count += 1
    this.loadResult()