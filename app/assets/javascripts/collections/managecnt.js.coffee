class Hooful.Collections.Managecnt extends Backbone.Collection
  url: '/api/manage_count_meet.json?type='
  initialize: (models, options) ->
        this.url += options.type+'&mCode='+options.mcode+'&mHost='+options.mhost