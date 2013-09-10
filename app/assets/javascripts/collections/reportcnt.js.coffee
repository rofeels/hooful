class Hooful.Collections.Reportcnt extends Backbone.Collection
  url: '/logreport/log_status.json?type='
  initialize: (models, options) ->
        this.url += options.type+'&mCode='+options.mcode