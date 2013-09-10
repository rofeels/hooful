#encoding: UTF-8
require 'openssl'
require 'net/http'
require 'base64'
require 'digest/sha1'
class PayController < ApplicationController
  respond_to :json
  
  include ApplicationHelper
  before_filter :authorize

	# 0. 유저 권한 필터링
  protected
  def authorize
    #@meet = Meet.load(params[:mCode]) if params[:mCode]
    if (params[:action] == "paysuccess" && request.post?) || (params[:action] == "payment" && request.post? && params[:payment] == "reload")
	  session[:user_id] = params[:mUserid]
    end
    if session[:user_id].nil?
      flash[:notice] = "올바른 접근이 아닙니다." 
      redirect_to "/home"
    end
  end

  public
  def payment
	@user = User.info(session[:user_id])
	if params[:payment] == "reload"
		@params = Hash.new
		@params[:mCode] = params[:mCode]
		@params[:mTitle] = params[:mTitle]
		@params[:unitprice] = params[:payprice]
		@params[:mPayUse] = params[:mPayUse]
		@params[:mPaytype] = params[:mPaytype]

		@ticketInfo = params[:ticketInfo]

		@ticketInfo.split("/,/").each_with_index do |value, i|
			if value
				tinfo = value.split("/+/")
				if i == 0 
					@params[:ticket_id] = Array.new
					@params[:ticket_name] = Array.new
					@params[:ticket_price] = Array.new
					@params[:ticket_oprice] = Array.new
					@params[:ticket_quantity] = Array.new
					@params[:ticket_description] = Array.new
				end
				@params[:ticket_id][i] = tinfo[0]
				@params[:ticket_name][i] = tinfo[1]
				@params[:ticket_price][i] = tinfo[2]
				@params[:ticket_quantity][i] = tinfo[3]
				@params[:ticket_description][i] = tinfo[4]
				@params[:ticket_oprice][i] = tinfo[5]
			end
		end
		@pay = Hash.new
		@pay[:use] = 1 if params[:mPayUse] == "1"
		@pay[:card] = 0
		@pay[:phone] = 0
		@pay[:account] = 0

		params[:mPaytype].split(',').each do |value|
			@pay[:card] =1 if value.strip == "card"
			@pay[:phone] =1 if value.strip == "801"
			@pay[:account] =1 if value.strip == "4"
		end
	else
		@params = params
		@pay = Hash.new
		@pay[:use] = 1 if params[:mPayUse] == "1"
		@pay[:card] = 0
		@pay[:phone] = 0
		@pay[:account] = 0

		params[:mPaytype].split(',').each do |value|
			@pay[:card] =1 if value.strip == "card"
			@pay[:phone] =1 if value.strip == "801"
			@pay[:account] =1 if value.strip == "4"
		end if params[:mPaytype]
		@ticketInfo = ""
		params[:ticket_name].each_with_index do |value, i|
      @nowticket = params[:ticket_name][i]  if params[:ticket_quantity][i] != "0"
      @nowticketd = params[:ticket_description][i]  if params[:ticket_quantity][i] != "0"
			@ticketInfo = "#{@ticketInfo}#{params[:ticket_id][i]}/+/#{params[:ticket_name][i]}/+/#{params[:ticket_price][i]}/+/#{params[:ticket_quantity][i]}/+/#{params[:ticket_description][i]}/+/#{params[:ticket_oprice][i]}/,/"  if params[:ticket_quantity][i] != "0"
		end if params[:ticket_name]
	end

	@ticket = Hash.new
	if @params[:mCode]
		mtmp = Meet.load(@params[:mCode])
		@ticket["title"] = @nowticket
		@ticket["description"] = @nowticketd
		@ticket["sdate"] =  "#{mtmp.end_date[5..6]}.#{mtmp.end_date[8..10]}"
		@ticket["address"] = "#{mtmp.mAddress}"
	end
  end
  def paysuccess
      redirect_to "/#{params[:mCode]}"

=begin
	if params[:mUserid]
		@tickets = TicketSold.where(:mUserid => params[:mUserid], :mCode => params[:mCode], :tState => 1)
		@meet = Meet.where(:mCode => params[:mCode]).first
		@category = Interest.where(:code => @meet.mCategory).first

	else
      flash[:notice] = "잘못된 접근입니다."
      redirect_to "/home"
	end
=end
  end


  def index
	#1. group member
	groupall = Group.where(:mCode => params[:mCode])
	group_member = GroupMember.where(:group_id.in => groupall.map(&:_id))
	@group_member = []
	@group_member_check = Hash.new
	group_member.each do |member|
		@group_member << member.mUserid
		@group_member_check["#{member.mUserid}"] = 1
	end
	#2. ticket buyer
	ticket_buyer = TicketSold.where(:mCode => params[:mCode], :tState => 1)
	@ticket_buyer = []
	@ticket_buyer_check = Hash.new
	ticket_buyer.each do |buyer|
		@ticket_buyer << buyer.mUserid
		@ticket_buyer_check["#{buyer.mUserid}"] = 1
	end
	#@participants = Member.any_of({:userid.in => @group_member.map(&:mUserid)},{:userid.in => @ticket_buyer.map(&:mUserid)})
	@participants = User.find(:all, :conditions => ["userid IN (?) or userid IN (?)", @ticket_buyer, @group_member])
	start = 0
	start = params[:size].to_i if params[:size]
	@particelist = []
	@participants[start..(start+LIST_LIMIT-1)].each do |partice|
		mtmp = Hash.new
		mtmp["userid"] = partice.userid
		mtmp["picture"] = partice.picture
		mtmp["name"] = partice.name
		mtmp["link"] = Home.encode(partice.userid)
		mtmp["ticket"] = 0
		mtmp["group"] = 0
		mtmp["ticket"] = 1 if @ticket_buyer_check["#{partice.userid}"]
		mtmp["group"] = 1 if @group_member_check["#{partice.userid}"]
		@particelist << mtmp
	end

	if @participants.count > (params[:size].to_f + LIST_LIMIT)
		mtmp = Hash.new
		mtmp["next"] = @participants.count-LIST_LIMIT
		@particelist << mtmp
	end
    respond_with @particelist
  end

  def show
  end

  def create
	if params[:type] == "pay"
		user = User.info(session[:user_id])
		user.phone = params[:phone] if params[:phone]
		user.dob = params[:dob] if params[:dob]
		user.local = params[:local] if params[:local]
		user.job = params[:job] if params[:job]
		user.save
		@payinfo = Payhistory.create_history(params)
		@ticket_info = TicketSold.create_ticket(params)
		groupall = Group.where(:mCode => params[:mCode])
		GroupMember.where(:mUserid => user.userid, :group_id.in => groupall.map(&:_id)).each do |group|
			Notification.send("group_new_buy", user.userid, group.group_id,params[:goodname])
		end

      #문자발송 - 구매완료(1)
      sParam = Hash.new
	  sParam[:userid] = user.userid
	  sParam[:mCode] = params[:mCode]
	  sParam[:ticket] = params[:goodname]
	  Smshistory.send("pay_success",sParam)      
	  Notification.send("ticket_buy", sParam[:userid],sParam[:mCode], sParam[:ticket])
		
	elsif params[:type] == "free"
		user = User.info(session[:user_id])
		user.phone = params[:phone] if params[:phone]
		user.dob = params[:dob] if params[:dob]
		user.local = params[:local] if params[:local]
		user.job = params[:job] if params[:job]
		user.save

		params[:mTickets] = []
		@ticket_info=params[:ticketInfo].split('/,/')
		@ticket_info = TicketSold.create_ticket(params)
		
	elsif params[:type] == "refund"

		@payinfo = Payhistory.where(:mCode => params[:mCode], :mUserid => params[:mUserid],:type => "buy").last
		uri = URI.parse('https://service.paygate.net/payment/pgtlCancel.jsp?pmemberid=ndysjo&pmemberpasshash=Hooful@payment&transactionid=' + @payinfo.tid.to_s)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
		@data = http.get(uri.request_uri)
		@data = @data.body.to_s.gsub!(/\n/,"")
		@refund = {}
		@data.split("&").each do |d|
			k,v = d.split('=')
			@refund[k] = v.to_s
		end
		@refund["mCode"] = params[:mCode]
		@refund["mUserid"] = params[:mUserid]
		@refundinfo = Payhistory.create_refund_history(@refund)
	elsif params[:type] == "confirmcancel"
	end
	render :json => {:result => true}
  end

end