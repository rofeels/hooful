class Hooful.Views.HoofulsCategory extends Backbone.View
  template: JST['hoofuls/category']
  tagName: 'span'

  events:
    'click .interest': 'addCategory'

  initialize: ->
    @count = 0
    @category = new Hooful.Collections.Categories()
    @category.fetch(success: =>
      @render()
    )
    
  render: ->
    $(@el).addClass('list').html(@template(category: @category))
    this

  addCategory: (event) ->
    target = (if $(event.target).hasClass("interest") then $(event.target) else $(event.target).parent("li"))
    code = (if $(event.target).hasClass("interest") then $(event.target).children("i").attr "class" else $(event.target).attr "class") 
    $("#mCategory").val code
    $("#hCreate .dropdown-toggle").html($(event.target).text()+"<span class=\"caret\"></span>")
    $("#hCreate .dropdown-menu li").removeClass("active")
    $(event.target).addClass("active")