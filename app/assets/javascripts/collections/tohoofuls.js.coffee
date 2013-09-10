class Hooful.Collections.Tohoofuls extends Backbone.Collection
  url: '/api/tohooful'

class Hooful.Collections.TohoofulsDetail extends Backbone.Collection
  url: '/api/tohooful/'
  initialize: (models, options) ->
        this.url += options.id