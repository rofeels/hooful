class Hooful.Collections.Validmeets extends Backbone.Collection
  url: '/api/valid_meet.json?'
  initialize: (models, options) ->
        this.url += 'mcode='+options.mcode