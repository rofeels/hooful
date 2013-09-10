class Hooful.Collections.Userstate extends Backbone.Collection
  url: '/api/user_state.json?'
  initialize: (models, options) ->
        this.url += 'type='+options.type+'&userid='+options.userid+'&tCode='+options.tCode

class Hooful.Collections.CommentEdit extends Backbone.Collection
  url: '/api/comment_edit'