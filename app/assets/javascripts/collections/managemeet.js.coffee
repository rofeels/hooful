class Hooful.Collections.Managemeet extends Backbone.Collection
  url: '/api/manage_meet.json?type='
  initialize: (models, options) ->
        this.url += options.type+'&mCode='+options.mcode+'&mHost='+options.mhost+'&order='+options.order+'&sort='+options.sort+'&keyword='+options.keyword

class Hooful.Collections.ManageReservedState extends Backbone.Collection
  url: '/api/sale_state_ticket'

class Hooful.Collections.ManageReservedStateCount extends Backbone.Collection
  url: '/api/sale_state_ticket_count'

class Hooful.Collections.ManageWithdrawmeet extends Backbone.Collection
  url: '/api/withdrawmeet'

class Hooful.Collections.ManageWithdrawinfo extends Backbone.Collection
  url: '/api/withdrawinfo'

class Hooful.Collections.ManageCodeTicket extends Backbone.Collection
  url: '/api/code_search'

class Hooful.Collections.ManageCodeUse extends Backbone.Collection
  url: '/api/code_use'

class Hooful.Collections.ManageWithdraw extends Backbone.Collection
  url: '/api/withdraw'

class Hooful.Collections.ManageWithdrawSet extends Backbone.Collection
  url: '/api/withdraw'

class Hooful.Collections.ManageWithdrawCalcurate extends Backbone.Collection
  url: '/api/withdraw_calcurate'

class Hooful.Collections.ManageWithdrawCalendar extends Backbone.Collection
  url: '/api/getWithdraw'

class Hooful.Collections.ManageWithdrawCalendarDetail extends Backbone.Collection
  url: '/api/getWithdrawDetail'
