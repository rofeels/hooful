#encoding: UTF-8
include ActionView::Helpers::NumberHelper #number_to_currency
class TicketController < ApplicationController
  respond_to :json
  LIMIT = 10
  USERLIMIT = 8
  def index
	 if params[:mUserid]
		if params[:lastTicket]
			@etickets = TicketSold.where(:mUserid =>params[:mUserid],:_id.lt =>params[:lastTicket], :tState => 10).desc(:created_at)
		else
			@etickets = TicketSold.where(:mUserid =>params[:mUserid], :tState => 10).desc(:created_at)
		end

		@tickets = []
		@etickets.limit(USERLIMIT).each do |ticket|
			mtmp = Meet.load(ticket.mCode)
			ttmp = Hash.new
			ttmp["_id"] = ticket._id
			ttmp["tName"] = ticket.tName
			ttmp["tDescription"] = ticket.tDescription
			ttmp["tCode"] = ticket.tCode
			ttmp["sYear"] = mtmp.end_date[0..3]
			ttmp["sMonth"] = mtmp.end_date[5..6]
			ttmp["sDay"] = mtmp.end_date[8..10]
			ttmp["mAddress"] = mtmp.mAddress
			@tickets << ttmp
		end
		if @etickets.count > USERLIMIT
			ttmp = Hash.new
			ttmp["next"] = @etickets.count
			@tickets << ttmp
		end
	else
		if params[:mCode] == ""
		  host_code = Meet.only(:mCode).where(:mHost => params[:mHost]).map(&:mCode)
		  @etickets = Ticket.where(:mCode.in => host_code)
		else
		  @etickets = Ticket.where(:mCode => params[:mCode])
		end
		
		@tickets = []
		@etickets.each do |ticket|
		  gtmp = Hash.new
		  gtmp["_id"] = ticket._id
		  gtmp["mCode"] = ticket.mCode
		  gtmp["tDescription"] = ticket.tDescription
		  gtmp["tName"] = ticket.tName
		  gtmp["tPrice"] = ticket.tPrice
		  gtmp["tOriginPrice"] = ticket.tOriginPrice
		  gtmp["tSupplyPrice"] = ticket.tSupplyPrice
		  gtmp["tPriceC"] = (ticket.tPrice == 0 || ticket.tPrice == '0')? "무료" : number_to_currency(ticket.tPrice, :locale => :ko) 
		  gtmp["tSold"] = TicketSold.where(:tId => gtmp["_id"], :tState => 1).sum(:tQuantity)
		  gtmp["tQuantity"] = ticket.tQuantity.to_i - gtmp["tSold"].to_i
		  gtmp["tLimit"] = gtmp["tQuantity"] >LIMIT ? LIMIT : gtmp["tQuantity"]
		  @tickets << gtmp
		end
	end
    respond_with @tickets
  end

  def show
    respond_with Ticket.all
  end

  def create
  end

end