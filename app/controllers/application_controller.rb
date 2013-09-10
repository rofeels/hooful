#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :protect
  helper_method :og, :myTicketList, :ticketState

  def og
	if @og.nil?
		@og = Hash.new
	end
	return @og
  end

  def myTicketList
    if session[:user_id]
      @ticket = TicketSold.listTicket(session[:user_id])
    else
      @ticket = 0
    end
    return @ticket
  end

  def ticketState(state)
    @TSTATE = ['구매완료','결제완료','예약신청','예약불가','예약변경','예약완료','환불신청','환불완료','출금신청','출금완료','사용완료']
    return @TSTATE[state]
  end

  def protect
	
	  @ips = ['210.91.80.6','112.218.1.171','125.180.104.147','112.150.42.21'] #And so on ...]
    if false
	  #if not @ips.include? request.remote_ip
      # Check for your subnet stuff here, for example
      # if not request.remote_ip.include?('127.0,0')
      render :text => "You are unauthorized"
      #render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
      return
    end
  end

end
