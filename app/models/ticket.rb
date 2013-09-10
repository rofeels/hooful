#encoding: UTF-8
include ActionView::Helpers::NumberHelper #number_to_currency
class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :tName, type: String
  field :tQuantity, type: Integer
  field :tPrice, type: Integer
  field :tOriginPrice, type: Integer
  field :tSupplyPrice, type: Integer
  field :tDescription, type: String

  validates_presence_of :tName, :message => "is empty"
  validates_numericality_of :tQuantity,only_integer: true, greater_than: 0
  validates_numericality_of :tPrice,only_integer: true, greater_than_or_equal_to: 0
  
  LIMIT =10

  def self.create_ticket(params)

    ticket_all = Array.new
    valid = true
    errormsg = ""
    params[:ticket_name].each_with_index do |value, i|
      ticket = Ticket.new

      ticket.mCode			= params[:mCode]
      ticket.tName			= params[:ticket_name][i]
      ticket.tQuantity		= params[:ticket_quantity][i]
      ticket.tPrice			= params[:ticket_price][i]
      ticket.tOriginPrice			= params[:ticket_origin_price][i]
      ticket.tSupplyPrice			= params[:ticket_supply_price][i]
      ticket.tDescription	= params[:ticket_description][i]
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

  def self.update_ticket(params)

    ticket_all = Array.new
    ticket_exist = Array.new
    valid = true
    errormsg = ""
    params[:ticket_name].each_with_index do |value, i|
      if params[:ticket_id] and params[:ticket_id][i]
		
        ticket = Ticket.find(params[:ticket_id][i])
        ticket.tName			= params[:ticket_name][i]
        ticket.tQuantity		= params[:ticket_quantity][i]
        ticket.tPrice			= params[:ticket_price][i]
        ticket.tOriginPrice			= params[:ticket_origin_price][i]
        ticket.tSupplyPrice			= params[:ticket_supply_price][i]
        ticket.tDescription	= params[:ticket_description][i]
        ticket.save
        ticket_exist << ticket  
      else
        ticket = Ticket.new
    
        ticket.mCode			= params[:mCode]
        ticket.tName			= params[:ticket_name][i]
        ticket.tQuantity		= params[:ticket_quantity][i]
        ticket.tPrice			= params[:ticket_price][i]
        ticket.tOriginPrice			= params[:ticket_origin_price][i]
        ticket.tSupplyPrice			= params[:ticket_supply_price][i]
        ticket.tDescription	= params[:ticket_description][i]
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
    end

	Ticket.where(:mCode => params[:mCode]).not_in(:_id => ticket_exist.map(&:_id)).each(&:destroy)
    if ticket_all.length > 0 and valid
        ticket_all.each(&:save)
    else
      errormsg
    end
  end

  def self.cheap_ticket(mParam)
    @arrayS = Array.wrap(nil)
	  @arrayS += Array.wrap("mCategory" => /.*#{mParam[:mCategory]}.*/)
    @cmeet = Meet.where("$or" => @arrayS)
    @cticket = []
    
    @cmeet.each do |cmeet|
      cticket = Ticket.where(:mCode => cmeet.mCode)
      cticket.each do |tc|
        tc["mPlace"] = cmeet[:mPlace]
        tc[:tPricetxt] = number_with_delimiter(tc[:tPrice].to_s, :delimiter => ',')
        @cticket << tc
      end
    end
    if mParam[:sort] == "asc"
		  @cticket.sort { |a,b| a[:tPrice] <=> b[:tPrice] }
    else
		  @cticket.sort { |a,b| b[:tPrice] <=> a[:tPrice] }      
    end
  end
  def price
	(self.tPrice > 0) ?number_to_currency(self.tPrice, :locale => :ko) :"무료"
  end
  def quantity_left
      sold_ticket = TicketSold.where(:tId => self._id, :tState => 1).sum(:tQuantity)
      self.tQuantity.to_i - sold_ticket.to_i
  end
  def quantity_limit
	  self.tQuantity >LIMIT ? LIMIT : self.tQuantity
  end
end