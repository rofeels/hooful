class Hooful.Views.HoofulsUpload extends Backbone.View

  template: JST['hoofuls/upload']
  tagName: 'div'
  
  events:
    'click #uploadComplete': 'uploadComplete'
    'change #uploadFile': 'uploadModal'
    'click #uploadResponse': 'uploadResponse'

  initialize: ->
    $('.picture').click (e) ->
      $('#uploader').modal()
      $("#uploadForm #uploadPath").val($(e.currentTarget).attr("path")) if $(e.currentTarget).attr("path")

  render: ->
    $(@el).html(@template(options: @options))
    this

  uploadModal: (event) ->
    $("#uploadForm").submit()
    $("#uploadForm .preview").after("<img src='http://d3o755op057jl1.cloudfront.net/hooful/loading.gif' class='loading'/>")
    $("#uploadComplete").attr "disabled", true

  uploadResponse: (event) ->
    unless $("#uploadFile").val is ""
      $("#uploadForm .preview").attr("src", "http://d3o755op057jl1.cloudfront.net/" + $("#uploadForm #uploadPath").val() + "/" + $("#uploadvURL").val())
      $("#uploadForm .loading").remove()
      $("#uploadComplete").attr "disabled", false
    else
      $("#uploadForm .preview").attr("src", "http://d3o755op057jl1.cloudfront.net/" + $("#uploadForm #uploadPath").val() + "/noimage.png")
      $("#uploadForm .loading").remove()
      $("#uploadURL").val "noimage.png"
      $("#uploadvURL").val "noimage.png"
      alert "파일 업로드에 실패했습니다."
      $("#uploadComplete").attr "disabled", false

  uploadComplete: (event) ->
    unless $("#uploadForm .btn").attr("disabled") is "disabled"
      $('#modalResponse').click()
      switch $("#uploadForm #uploadPath").val()
        when "meetpic"
          $(".picture img").attr "src", $("#uploadForm .preview").attr("src")
          $("#mPicture").val $("#uploadvURL").val()
          $("#mPicturename").val $("#uploadURL").val()
        when "userpic"
          $("#previewuserpic").attr("src", $("#uploadForm .preview").attr("src")).css("width", "201px").css "height", "201px"
          $("#userpic").val "hooful"
          $("#userpicCopy").val "hooful"
          $("#userpicname").val $("#uploadvURL").val()
          $(".picture[path='userpic'] img").attr "src", $("#uploadForm .preview").attr("src")
          $("#uploadFile").val ""
          $("#uploadForm .preview").attr "src", "http://cdn.hooful.com/meetpic/preregist_noimage.png"
        when "reviewpic"
          $("#picture_area").children("img").attr("src", $("#uploadForm .preview").attr("src")).css "z-index", "1"
          $("#picture_area").css "z-index", "-1"
          $("#mPicture").val $("#uploadURL").val()
          $("#mPicturename").val $("#uploadvURL").val()
        when "coverpic"
          $("#picture_area").next("img").attr("src", $("#uploadForm .preview").attr("src")).css "z-index", "1"
          $("#picture_area").css "z-index", "-1"
          $("#mPicture").val $("#uploadURL").val()
          $("#mPicturename").val $("#uploadvURL").val()
          $(".picture[path='coverpic'] img").attr "src", $("#uploadForm .preview").attr("src")
          $("#uploadFile").val ""
          $("#uploadForm .preview").attr "src", "http://cdn.hooful.com/meetpic/preregist_noimage.png"
        when "certificatioin"
          $("#previewuserpic").attr("src", $("#uploadForm .preview").attr("src")).css("width", "201px").css "height", "201px"
          $("#certpic").val $("#uploadURL").val()
          $("#certpicname").val $("#uploadvURL").val()
          $(".picture[path='certificatioin'] img").attr("src",$("#uploadForm .preview").attr("src")).show()
          $(".picture[path='certificatioin'] .wrap").hide()
          $("#uploadFile").val ""
          $("#uploadForm .preview").attr "src", "http://cdn.hooful.com/meetpic/preregist_noimage.png"
        else