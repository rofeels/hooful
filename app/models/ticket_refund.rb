#encoding: UTF-8
class TicketRefund
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :mUserid, type: String
  field :orderId, type: String
  field :tId, type: String
  field :tPrice, type: Integer
  field :tRequestDate, type: String
  field :tRefundDate, type: String
  field :tRefundState, type: String
  field :tRefundDescription, type: String

  validates_numericality_of :tPrice,only_integer: true, greater_than_or_equal_to: 0

  def self.create_refund(params)
    ticket_all= Array.new
    valid = true
    errormsg = ""
    if params[:tPrice]!=0
      ticket = TicketRefund.new
      ticket.tPrice			= params[:tPrice]
      ticket.mCode			= params[:mCode]
      ticket.mUserid			= params[:mUserid]
      ticket.orderId			= params[:orderid]
      ticket.tId			= params[:tid]
      ticket.tRequestDate	= Time.now.strftime("%Y. %m. %d %H:%M:%S")
      ticket.tRefundDate	= ""
      ticket.tRefundState	= 0
      ticket.tRefundDescription	= ""
      if ticket.valid?
        ticket_all << ticket  
      else
        valid = false
        returnmsg = ""
        ticket.errors.full_messages.each do |msg|
          returnmsg += msg+"\n"
        end
        errormsg += returnmsg
      end
    end  
    if valid
        ticket_all.each(&:save)
    else
      errormsg
    end
  end
end
