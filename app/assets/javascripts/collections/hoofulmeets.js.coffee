class Hooful.Collections.Hoofulmeets extends Backbone.Collection
  url: '/api/card_load.json?page='
  initialize: (models, options) ->
        this.url += options.page+'&order='+options.order+'&keyword='+options.keyword

class Hooful.Collections.Hoofulpersons extends Backbone.Collection
  url: '/api/person_load.json?page='
  initialize: (models, options) ->
        this.url += options.page+'&order='+options.order+'&keyword='+options.keyword

class Hooful.Collections.Communitymeets extends Backbone.Collection
  url: '/api/community_load.json?page='
  initialize: (models, options) ->
        this.url += options.page+'&order='+options.order+'&keyword='+options.keyword+'&mCategory='+options.category+'&cardnum='+options.limit

class Hooful.Collections.Hostinfo extends Backbone.Collection
  url: '/api/hostinfo'

class Hooful.Collections.HooChkCode extends Backbone.Collection
  url: '/api/pluginChkCode'

class Hooful.Collections.HooAddLike extends Backbone.Collection
  url: '/api/pluginMeetAddLike'

class Hooful.Collections.HooDelLike extends Backbone.Collection
  url: '/api/pluginMeetDelLike'