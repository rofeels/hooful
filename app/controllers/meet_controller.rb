#encoding: UTF-8
class MeetController < ApplicationController
  include ApplicationHelper
  before_filter :authorize, :only => [:show]
  before_filter :authorize_update, :only => [:update]

	# 0. 유저 권한 필터링
  protected
  def authorize
    #@meet = Meet.load(params[:mCode]) if params[:mCode]
    if params[:hMethod] == "generate" && request.post?
	  session[:user_id] = params[:mHost]

    end
    if session[:user_id].nil?
      flash[:notice] = "올바른 접근이 아닙니다." 
      redirect_to "/home"
    #elsif  @meet[:mCode] and (@meet[:mHost] != session[:user].userid)
    #  flash[:notice] = "접근 권한이 없습니다."
    #  redirect_to "/home"
    end
  end

  def authorize_update
    @meet = Meet.load(params[:mCode]) if params[:mCode]
    if (session[:user_id] == @meet.mHost) or (session[:user_id] == "hooful@hooful.com")			
    #if true
    else
      if params[:sId].nil?
        flash[:notice] = "접근 권한이 없습니다."
        redirect_to "/home"
      else
        if session[:user_id].nil? and ((params[:sId] == params[:mHost]) or (params[:sId] == "hooful@hooful.com"))
          session[:user_id] = params[:sId]
        else
          flash[:notice] = "접근 권한이 없습니다."
          redirect_to "/home"
        end
      end
    end
  end
  # 0. 유저 권한 필터링

  public

  def index
    if (params[:mCode] == "#_=_") or (params[:mCode] == "_=_")
          redirect_to "/"
	else

		LogMeetview.savelog(request.env["HTTP_X_FORWARDED_FOR"],session[:user_id],params[:mCode],request.referer)
		
	
		@meet = Meet.load(params[:mCode])
		@host = @meet.host if @meet
		#@count = Interest.count_category(@meet.mCategory) if @meet
		@group_count = Group.where(:mCode => params[:mCode]).count
		
		@og = Hash.new
		@og[:title] = @meet.mTitle
		@og[:mCode] = @meet.mCode
		@og[:description] = @meet.mSummary
		@og[:site_name] = "후풀 - Work hard, Play hard"
		@og[:image] = "http://cdn.hooful.com/meetpic/thumb/"+@meet.mPicture

		@particestate =0
		partice_info = TicketSold.where(:mUserid => session[:user_id] ,:mCode => params[:mCode], :tState.lte => 5, :tState.gte => 1).first if session[:user_id]
		@particestate = partice_info.tState if !partice_info.nil?
		
		@likeinfo = Hoolike.hoocounturl("http://#{request.host}/c/#{@meet.mCategory}", (session[:user_id] if session[:user_id]))

    @visituser = User.info(session[:user_id])
		@particecheck = false
		if @visituser
			if @visituser.sex == 1 #남자
				if @meet.mMale > @meet.uMale
					@particecheck = true
				end
			else
				if @meet.mFemale > @meet.uFemale
					@particecheck = true
				end	
			end		
		else
			@particecheck = false
		end
	end    
  end

  def show
    #@meet = Meet.load(params[:mCode])
    #@host = @meet.host if @meet

    @emeet = Meet.where(:mHost => session[:user_id])
    @mwith = Hash.new
    @mwith[:accSales] = 0
    @mwith[:accUse] = 0
    @mwith[:accSalesPrice] = 0
    @mwith[:accRefundEnd] = 0
    @mwith[:accRefunding] = 0
    @mwith[:accRefund] = 0
    @emeet.each do |meet|
      ticket_sold = TicketSold.where(:mCode => meet.mCode)
      ticket_sold.each do |tsold|
        @mwith[:accSales] += 1
        @mwith[:accUse] += 1 if tsold.tUse == 1
        @mwith[:accSalesPrice] += tsold.tPrice
        case tsold.tState
          when 10
            @mwith[:accRefund] += tsold.tPrice
          when 8
            @mwith[:accRefunding] += tsold.tPrice
          when 9
            @mwith[:accRefundEnd] += tsold.tPrice
        end
      end
    end
  end

  def withdraw
    @wAcc = Withdraw.where(:mUserid => session[:user_id]).last
    @wAcc ||= Hash.new
    @emeet = Meet.where(:mHost => session[:user_id])
    @mwith = Hash.new
    @mwith[:accSales] = 0
    @mwith[:accUse] = 0
    @mwith[:accSalesPrice] = 0
    @mwith[:accRefundEnd] = 0
    @mwith[:accRefunding] = 0
    @mwith[:accRefund] = 0
    @emeet.each do |meet|
      ticket_sold = TicketSold.where(:mCode => meet.mCode)
      ticket_sold.each do |tsold|
        @mwith[:accSales] += 1
        @mwith[:accUse] += 1 if tsold.tUse == 1
        @mwith[:accSalesPrice] += tsold.tPrice
        case tsold.tState
          when 10
            @mwith[:accRefund] += tsold.tPrice
          when 8
            @mwith[:accRefunding] += tsold.tPrice
          when 9
            @mwith[:accRefundEnd] += tsold.tPrice
        end
      end
    end
  end

  def create
	@user = User.info(session[:user_id])
    if params[:hMethod] == "generate" && request.post?
      @create_result = Meet.create_meet(params)
      
      if @create_result == true
        Ticket.create_ticket(params)
        Notification.send("new", @user , params[:mCode],1)
        HardWorker.tweet(params,@user ,'meet') if params["tuid"]== '1'
        HardWorker.fbfeed(params,@user ,'meet') if params["fuid"]=='1'
        flash[:mCode] = params[:mCode]
        redirect_to "/meet/subscription"
        #redirect_to "/"+params[:mCode]
      elsif @create_result == false
        flash[:notice] = "오류가 발생했습니다. 활동생성이 되지 않았습니다."
        redirect_to :controller => 'home', :action => 'index'
      else
        flash[:notice] = "작성된 내용이 부족합니다. 활동생성이 되지 않았습니다."
        redirect_to :back
      end
    else
      if @user.email_auth.to_s != "1"
        flash[:notice] = "활동을 만들기 위해서 이메일인증을 해주세요."
        redirect_to :controller => 'home', :action => 'index'
      end		
	  @reopen = Meet.where(:mHost => session[:user_id])
	  @meet_time = Array.new
	  Array.new(24.hours / 30.minutes) do |i|
	    @meet_time << [ (Time.now.midnight + (i*30.minutes)).strftime("%I:%M %p"), i /2.0]
	  end
    end
  end

  def subscription
    
  end

  def update
	@user = User.info(session[:user_id])
    if params[:hMethod] == "generate" && request.post?
      @create_result = Meet.update_meet(params)
      
      if @create_result == true
        @ticket_update = Ticket.update_ticket(params)
        Notification.send("edit", @user, params[:mCode],1)
        #HardWorker.tweet(params,@user,'meet') if params["tuid"]== '1'
        #HardWorker.fbfeed(params,@user,'meet') if params["fuid"]=='1'
        redirect_to "/"+params[:mCode]
      elsif @create_result == false
        flash[:notice] = "오류가 발생했습니다. 활동이 수정되지 않았습니다."
        redirect_to :controller => 'home', :action => 'index'
      else
        flash[:notice] = "#{@create_result.inspect} 작성된 내용이 부족합니다. 활동이 수정 되지 않았습니다."
        redirect_to :back
      end
    else
=begin      
      if session[:user].email_auth.to_s != "1"
        flash[:notice] = "활동을 수정하기 위해서 이메일인증을 해주세요."
        redirect_to :controller => 'home', :action => 'index'
      end		
=end
	  @meet = Meet.where(mCode: params[:mCode]).first # for mongo
	  @meet_time = Array.new
	  Array.new(24.hours / 30.minutes) do |i|
	    @meet_time << [ (Time.now.midnight + (i*30.minutes)).strftime("%I:%M %p"), i /2.0]
	  end	
    end
  end


  def community
    @count = Interest.count_category(params[:mCategory]) if params[:mCategory]
    @category = Interest.load(params[:mCategory])
    @category[:group] = Group.where(:gCategory =>params[:mCategory]).count
    @hoolike = Hoolike.hoolikeurl("http://#{request.host}/c/#{params[:mCategory]}").desc(:created_at).limit(10)
	@likeinfo = Hoolike.hoocounturl("http://#{request.host}/c/#{params[:mCategory]}", (session[:user_id] if session[:user_id]))
	@user = User.info(session[:user_id]) if session[:user_id]
  end
  def reservation
    @ticket = TicketSold.choiceTicket(session[:user_id], params[:mCode])
    @user = User.info(session[:user_id])
  end
end
