class Hooful.Views.HoofulsNotification extends Backbone.View

  template: JST['hoofuls/notification']
  tagName: 'div'

  events:
    'click .more': 'loadMore'

  initialize: ->
    _.bindAll(this, 'load')
    @unchecked =0
    @load()
    parent = @
    $("#hNotice").hover ( ->
      $(this).addClass("set")      
      $("#hNoticeWrap").show()
      parent.noticeCheck()  unless $("#hNoticeWrap").css("display") is "none"
    ), ->
      $(this).removeClass("set")      
      $("#hNoticeWrap").hide()
      parent.noticeCheck()  unless $("#hNoticeWrap").css("display") is "none"
    socket.on "updatenotice", @load
    
  render:(size) ->
    size = (if (size) then size else 3)  
    $(@el).html(@template(notification:@notification,size:size))
    this
    
  load:(size) ->
    @notification = new Hooful.Collections.Notifications()
    @notification.fetch(
      data: {userid: userid}
      type: "GET"
      success: =>
        @unchecked =  new String(JSON.stringify(@notification.models[@notification.length-1]))
        @unchecked = parseInt(@unchecked.replace("\{\"0\"\:","").replace("\}",""))
        if @unchecked > 0 
          $('#hNotice .unchecked').text(@unchecked).show()
        else
          $('#hNotice .unchecked').text(@unchecked).hide()
        @render(size)
        @noticeCheck() unless $("#hNoticeWrap").css("display") is "none"
    )
  noticeCheck: ->
    nid = ""
    $("#hNoticeWrap #hNoticeList ul li.uncheck").each (index) ->
      nid += $(this).attr("nid") + ","

    @noticheck = new Hooful.Collections.Notifications()
    @noticheck.fetch(
      data: {userid: userid,noticenid: nid,type: "check"}
      type: "POST"
      success: =>
        result = @noticheck.models[0].get('result')
        if result is 0
          $("#hNotice .unchecked").fadeOut 1500, ->
            $("#hNotice .unchecked").text result
        else
          $("#hNotice .unchecked").text(result).fadeIn 1500
        $("#hNoticeWrap #hNoticeList ul li.uncheck").animate(
         backgroundColor: "#ffffff"
        , 1500).removeClass "uncheck"
    )

  loadMore:(event) ->
    noticenum = parseInt($("#hNoticeWrap #hNoticeList ul li").size())
    size = 3
    @load(noticenum+size)
    
class Hooful.Views.HoofulsNotificationList extends Backbone.View

  template: JST['hoofuls/notification']
  tagName: 'div'

  events:
    'click .more': 'loadMore'
    
  initialize: ->
    _.bindAll(this, 'load')
    @load()
    @noticeCheck()
  render:(size) ->
    size = (if (size) then size else 20)  
    $(@el).html(@template(notification:@notification,size:size))
    this
    
  loadMore:(event) ->
    noticenum = parseInt($("#hNotification #hNoticeList ul li").size())
    size = 20
    @load(noticenum+size)   
    
  load:(size) ->
    @notification = new Hooful.Collections.Notifications()
    @notification.fetch(
      data: {userid: userid}
      type: "GET"
      success: =>
        @render(size)
        @noticeCheck()
    ) 

  noticeCheck: ->
    nid = ""
    $("#hNotification #hNoticeList ul li.uncheck").each (index) ->
      nid += $(this).attr("nid") + ","

    @noticheck = new Hooful.Collections.Notifications()
    @noticheck.fetch(
      data: {userid: userid,noticenid: nid,type: "check"}
      type: "POST"
      success: =>
        result = @noticheck.models[0].get('result')
        if result is 0
          $("#hNotice .unchecked").fadeOut 1500, ->
            $("#hNotice .unchecked").text result
        else
          $("#hNotice .unchecked").text(result).fadeIn 1500
        $("#hNotification #hNoticeList ul li.uncheck").animate(
         backgroundColor: "#ffffff"
        , 1500).removeClass "uncheck"
    )

    