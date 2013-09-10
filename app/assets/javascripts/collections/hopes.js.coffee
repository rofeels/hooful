class Hooful.Collections.Hopes extends Backbone.Collection
  url: '/api/hope'

class Hooful.Collections.HopeDetail extends Backbone.Collection
  url: '/api/hope/'
  initialize: (models, options) ->
        this.url += options.id

class Hooful.Collections.HopeCmts extends Backbone.Collection
  url: '/api/hopecmt'
