class Hooful.Collections.Groups extends Backbone.Collection
  url: '/api/group'
  model: Hooful.Models.Groups

class Hooful.Collections.GroupCount extends Backbone.Collection
  url: '/api/groupcount'

class Hooful.Collections.Group extends Backbone.Collection
  url: '/api/group'
  initialize: (models, options) ->
        this.url += '/'+options.gid

class Hooful.Collections.GroupCategory extends Backbone.Collection
  url: '/api/group_category'

class Hooful.Collections.CertAuth extends Backbone.Collection
  url: '/api/cert_auth'
