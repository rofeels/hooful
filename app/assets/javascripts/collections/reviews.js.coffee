class Hooful.Collections.Reviews extends Backbone.Collection
  url: '/api/review'

class Hooful.Collections.ReviewDetail extends Backbone.Collection
  url: '/api/review/'
  initialize: (models, options) ->
        this.url += options.id

class Hooful.Collections.ReviewCmts extends Backbone.Collection
  url: '/api/reviewcmt'

class Hooful.Collections.ReviewMeets extends Backbone.Collection
  url: '/api/reviewmeet'
