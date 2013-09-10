class Hooful.Views.HoofulsSearchBar extends Backbone.View

  template: JST['hoofuls/searchbar']
  initialize: ->
    _.bindAll(this, 'hideSearch', 'keySearch')
    $('#mSearch').keypress(this.keySearch);
    $('#hContainer').click(this.hideSearch);
    $('#hUserNav, #hNotice, #hTicket').hover(this.hideSearch);
    
    $('#hSearchIcon .icon').click ->
      if $('#hSearchBar').css("display") is "none"
        $("#hSearchIcon").addClass("set")
        $("#hSearchIcon").css "background-position", "-30px 0"

        $('#hSearchBar').slideDown('slow')
        $('#hContainer').animate
          marginTop: "90px"
        , 600
        $('#hSearchIcon').hover (->
          $("#hSearchIcon").css "background-position", "-30px 0"
        ), ->
          $("#hSearchIcon").css "background-position", "-30px 0"
      else
        $("#hSearchIcon").removeClass("set")
        $("#hSearchIcon").css "background-position", "0 0"
        #$(".searchBar").slideUp(300).fadeOut(300).hide(300)
        $('#hSearchBar').slideUp('slow')
        $('#hContainer').animate
          marginTop: "45px"
        , 600
        $('#hSearchIcon').hover (->
          $("#hSearchIcon").css "background-position", "-30px 0"
        ),->
          $("#hSearchIcon").css "background-position", "0 0"

  render: ->
    #$(@el).html(@template(options: @options))
    this

  hideSearch: ->
    if $('#hSearchBar').css("display") isnt "none"
      $("#hSearchIcon").css "background-position", "0 0"
      $('#hSearchBar').slideUp('slow')
      if $('#hSearchBar').length
        $('#hContainer').animate
          marginTop: "45px"
        , 600
      
      $('#hSearchIcon').hover (->
        $("#hSearchIcon").css "background-position", "-30px 0"
      ),->
        $("#hSearchIcon").css "background-position", "0 0"
      $("#hSearchIcon").removeClass("set")

  keySearch: (e) ->
    if e.keyCode == 13 or e.keyCode == 3
      document.location.href = "/search/"+$('#mSearch').val();
      false
   false