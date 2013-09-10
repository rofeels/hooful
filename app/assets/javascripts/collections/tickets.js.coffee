class Hooful.Collections.Tickets extends Backbone.Collection
  url: '/api/ticket'
  model: Hooful.Models.Tickets

class Hooful.Collections.Ticketsale extends Backbone.Collection
  url: '/api/sale_ticket.json'
  model: Hooful.Models.Tickets

class Hooful.Collections.Ticketsalewithdraw extends Backbone.Collection
  url: '/api/withdraw_ticket.json'
  model: Hooful.Models.Tickets

class Hooful.Collections.chkCountTicketsold extends Backbone.Collection
  url: '/api/chkCountTicketsold.json'
  model: Hooful.Models.Tickets

class Hooful.Collections.chkChoiceTicketsold extends Backbone.Collection
  url: '/api/choiceTicket.json'
  model: Hooful.Models.Tickets

class Hooful.Collections.reservCode extends Backbone.Collection
  url: '/api/reservCode.json'
  model: Hooful.Models.Tickets

class Hooful.Collections.changeTicketState extends Backbone.Collection
  url: '/api/changeState.json'
  model: Hooful.Models.Tickets

class Hooful.Collections.detailTicketsold extends Backbone.Collection
  url: '/api/detailTicketCode.json'
  model: Hooful.Models.Tickets