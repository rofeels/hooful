class Hooful.Views.HoofulsLike extends Backbone.View

  initialize: ->
    _.bindAll(this, 'likeUpdate')
    if typeof (userid) is "string" and userid isnt ""
      hoo = $(".hoo-plugin")
      that = @
      $(".hoo-action").click ->
       that.likeUpdate(hoo.attr("hoo-user"), hoo.attr("hoo-url"))
    
  likeUpdate: (user, url) ->
    @likelist = new Hooful.Collections.LikeList()
    @likelist.fetch(
      data: {user: user, url: url}
      type: "GET"
      success: =>
        likelist = new Hooful.Views.HoofulsLikeList(@likelist)
        $('.hchPerson dd').html(likelist.render().el)
        $('.hcInfo .like .num').text(@likelist.models.length)
    )
    
class Hooful.Views.HoofulsLikeList extends Backbone.View
    
  template: JST['hoofuls/like_list']
  initialize: ->
  
  render: ->
    $(@el).html(@template(likelists: @options))
    this
