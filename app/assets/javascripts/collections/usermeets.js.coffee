class Hooful.Collections.Usermeets extends Backbone.Collection
  url: '/api/user_meet.json?'
  initialize: (models, options) ->
        this.url += 'type='+options.type+'&userid='+options.userid+'&page='+options.page

class Hooful.Collections.ReMeets extends Backbone.Collection
  url: '/api/reopen'

class Hooful.Collections.Company extends Backbone.Collection
  url: '/api/company'
