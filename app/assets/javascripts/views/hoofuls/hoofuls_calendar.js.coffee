class Hooful.Views.HoofulsCalendar extends Backbone.View
  template: JST['hoofuls/calendar']
  tagName: 'div'
  
  events:
    'click .left': 'prevMonth'
    'click .right': 'nextMonth'
    'click .date': 'selectDate'

  initialize: ->
    @monthString = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    #@monthString = ["January","February","March","April","May","June","July","August","September","October","November","December"]

    today = new Date()
    @dd = today.getDate()
    @mm = today.getMonth()
    @yyyy = today.getFullYear()
    @title = @monthString[@mm]
    @prev_lastday = new Date(@yyyy,@mm,0)
    @prev_lastday = @prev_lastday.getDate()
    @lastday = new Date(@yyyy,@mm+1,0)
    @lastday = @lastday.getDate()
    @weekday = new Date(@yyyy,@mm,1)
    @weekday = @weekday.getDay()
    @remain = (@lastday+@weekday)%7

  render: (target_val, target) ->
    target = (if target then target else @el)
    $(target).addClass('calendar').attr("year", @yyyy).attr("month", @mm+1).html(@template(title: @title, year: @yyyy, month: @mm+1, lastday: @lastday, prev_lastday: @prev_lastday, weekday: @weekday, remain: @remain, target_val: target_val))
    this

  prevMonth: (event) ->
    target = $(event.target).parent().parent()
    target_val = target.parent().attr "target"
    today = new Date(target.attr('year'), target.attr('month')-2, 1);
    @dd = today.getDate()
    @mm = today.getMonth()
    @yyyy = today.getFullYear()
    @title = @monthString[@mm]
    @prev_lastday = new Date(@yyyy,@mm,0)
    @prev_lastday = @prev_lastday.getDate()
    @lastday = new Date(@yyyy,@mm+1,0)
    @lastday = @lastday.getDate()
    @weekday = new Date(@yyyy,@mm,1)
    @weekday = @weekday.getDay()
    @remain = (@lastday+@weekday)%7
    @render(target_val,target)

  nextMonth: (event) ->
    target = $(event.target).parent().parent()
    target_val = target.parent().attr "target"
    today = new Date(target.attr('year'), parseInt(target.attr('month')), 1);
    @dd = today.getDate()
    @mm = today.getMonth()
    @yyyy = today.getFullYear()
    @title = @monthString[@mm]
    @prev_lastday = new Date(@yyyy,@mm,0)
    @prev_lastday = @prev_lastday.getDate()
    @lastday = new Date(@yyyy,@mm+1,0)
    @lastday = @lastday.getDate()
    @weekday = new Date(@yyyy,@mm,1)
    @weekday = @weekday.getDay()
    @remain = (@lastday+@weekday)%7
    @render(target_val,target)
    
  selectDate: (event) ->
    event = $(event.target)
    status = event.hasClass "active"
    target = event.parent().parent().parent().attr "target"
    target_val = $("#" + target).val()
    target_type = $("#" + target).attr "count"
    if event.hasClass("disabled") is false
      if status      
        $("#" + target).val(target_val.replace(event.attr("date") + ", ","")).change()
        event.removeClass "active"
      else
        if target_type is '1'
          event.parent('ul').children('.date').removeClass "active"
          $("#" + target).val(event.attr("date") + ", ").change()
          event.addClass "active"
          event.parent().parent().parent().find("span").text(event.attr("date")) unless $("#" + target).attr("count") is "1"
          event.parent().parent().parent().find(".tDate").text(event.attr("date")) if $("#" + target).attr("count") is "1"
        else
          $("#" + target).val(target_val + event.attr("date") + ", ").change()
          event.addClass "active"

class Hooful.Views.HoofulsCalendarLarge extends Backbone.View
  template: JST['hoofuls/calendar_large']
  tagName: 'div'
  
  events:
    'click .left': 'prevMonth'
    'click .right': 'nextMonth'
    'click .date': 'selectDate'

  initialize: ->
    @monthString = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    #@monthString = ["January","February","March","April","May","June","July","August","September","October","November","December"]

    today = new Date()
    @dd = today.getDate()
    @mm = today.getMonth()
    @yyyy = today.getFullYear()
    @title = @yyyy + '년 ' + @monthString[@mm]
    @prev_lastday = new Date(@yyyy,@mm,0)
    @prev_lastday = @prev_lastday.getDate()
    @lastday = new Date(@yyyy,@mm+1,0)
    @lastday = @lastday.getDate()
    @weekday = new Date(@yyyy,@mm,1)
    @weekday = @weekday.getDay()
    @remain = (@lastday+@weekday)%7

  render: (target_val, target) ->
    @sales = new Hooful.Collections.ManageWithdrawCalendar()
    @sales.fetch(
      data: {
        mYear: @yyyy,
        mMonth: @mm+1
        mHost: $('.hManage').attr('mhost')
      }
      type: "GET"
      success: =>
        target = (if target then target else @el)
        $(target).addClass('calendar').addClass('large').addClass('wrap').attr("year", @yyyy).attr("month", @mm+1).html(@template(title: @title, year: @yyyy, month: @mm+1, lastday: @lastday, prev_lastday: @prev_lastday, weekday: @weekday, remain: @remain, target_val: target_val, money: @sales))
    )
    this

  prevMonth: (event) ->
    target = $(event.target).parent().parent()
    target_val = target.parent().attr "target"
    today = new Date(target.attr('year'), target.attr('month')-2, 1);
    @dd = today.getDate()
    @mm = today.getMonth()
    @yyyy = today.getFullYear()
    @title = @yyyy + '년 ' + @monthString[@mm]
    @prev_lastday = new Date(@yyyy,@mm,0)
    @prev_lastday = @prev_lastday.getDate()
    @lastday = new Date(@yyyy,@mm+1,0)
    @lastday = @lastday.getDate()
    @weekday = new Date(@yyyy,@mm,1)
    @weekday = @weekday.getDay()
    @remain = (@lastday+@weekday)%7
    @render(target_val,target)

  nextMonth: (event) ->
    target = $(event.target).parent().parent()
    target_val = target.parent().attr "target"
    today = new Date(target.attr('year'), parseInt(target.attr('month')), 1);
    @dd = today.getDate()
    @mm = today.getMonth()
    @yyyy = today.getFullYear()
    @title = @yyyy + '년 ' + @monthString[@mm]
    @prev_lastday = new Date(@yyyy,@mm,0)
    @prev_lastday = @prev_lastday.getDate()
    @lastday = new Date(@yyyy,@mm+1,0)
    @lastday = @lastday.getDate()
    @weekday = new Date(@yyyy,@mm,1)
    @weekday = @weekday.getDay()
    @remain = (@lastday+@weekday)%7
    @render(target_val,target)
    
  selectDate: (event) ->
    event = $(event.target)
    status = event.hasClass "active"
    target = event.parent().parent().parent().attr "target"
    target_val = $("#" + target).val()
    target_type = $("#" + target).attr "count"
    @wdetail = new Hooful.Collections.ManageWithdrawCalendarDetail()
    @wdetail.fetch(
      data: {
        mDate: event.attr('date')
        mHost: $('.hManage').attr('mhost')
      }
      type: "GET"
      success: =>
        if @wdetail.models.length > 0
          $("#calendar_modal").remove()
          review_detail = new Hooful.Views.HoofulsCalendarDetail(@wdetail)
          $('body').append(review_detail.render().el)
          $("#calendar_modal").modal()
    )

class Hooful.Views.HoofulsCalendarDetail extends Backbone.View

  template: JST['hoofuls/calendar_detail']
  tagName: 'div'
    
  initialize: (options) ->
    
  render:(size) ->
    $(@el).addClass("modal hide fade in").attr("id","calendar_modal").html(@template(detail:@options))
    this