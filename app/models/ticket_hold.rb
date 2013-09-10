#encoding: UTF-8
class TicketHold
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :mUserid, type: String
  field :tQuantity, type: Integer
  field :tId, type: String

  def self.ticket_hold(params)
	ticket = TicketHold.new
	ticket.mCode			= params[:mCode]
	ticket.mUserid			= params[:mUserid]
	ticket.tQuantity		= params[:tQuantity]
	ticket.tId			= params[:tId]
	ticket.save
  end
end