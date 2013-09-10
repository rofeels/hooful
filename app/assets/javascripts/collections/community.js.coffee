class Hooful.Collections.CommunityTalk extends Backbone.Collection
  url: '/api/community_talk'
  model: Hooful.Models.CommunityTalks

class Hooful.Collections.CommunityTicket extends Backbone.Collection
  url: '/api/cheap_ticket.json?mCategory='
  initialize: (models, options) ->
        this.url += options.mCategory+'&sort='+options.sort

class Hooful.Collections.CommunityDoc extends Backbone.Collection
  url: '/api/community_document'

class Hooful.Collections.CommunityDocDetail extends Backbone.Collection
  url: '/api/community_document/'
  initialize: (models, options) ->
        this.url += options.id

class Hooful.Collections.LikeList extends Backbone.Collection
  url: '/api/likelist'
        
        
