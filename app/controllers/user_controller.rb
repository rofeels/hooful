#encoding: utf-8
class UserController < ApplicationController
  require 'omniauth-facebook'
  require 'omniauth-twitter'
  require 'omniauth'
  before_filter :authorize, :only => [:update, :update_certification, :update_password, :update_sns, :update_notification, :update_category, :ticket,:ticket_old,:ticket_detail,:ticket_cancel,:ticket_reserved,:ticket_cancel_create]

  protected
  def authorize
    session[:user_id] = params[:userid] if params[:userid]
    if session[:user_id].blank?
      flash[:notice] = "로그인 해주시기 바랍니다."
      redirect_to "/signin"
    end
  end

  public

  def show
    if params[:userid]
      @user = User.info(Home.decode(params[:userid]))
    elsif session[:user_id]		
      @user = User.info(session[:user_id])
    end
	@user.comment = "소개글을 입력해주세요." if @user.comment.blank?

    if @user and @user.userid
      @user
      @meet_participated = @user.meet_participated
      #@meet_hosted = @user.meet_hosted
      #@meet_hooed = @user.meet_hooed
    else
      flash[:notice] = "회원이 없습니다."
      redirect_to "/home"
    end
  end

  def index
    if params[:returnurl]
      session[:returnurl] = params[:returnurl]
    end
  	if session[:user_id]
      redirect_to "/home"
  	elsif params[:userid] and params[:password]
	  user = User.signin(params[:userid],params[:password])
	  if user and request.post?
		  session[:user_id] = params[:userid]
		  flash[:notice] = "#{user.name}님, 환영합니다~"
		  if session[:returnurl]
        redirect_to session[:returnurl]
        session[:returnurl] = nil
      else
        redirect_to "/home"
      end
		  Notification.LoginCheck(session[:user_id])
	  else
		  flash[:notice] = "이메일 혹은 비밀번호가 틀립니다."
		  redirect_to "/signin"
	  end
    else
	  render :layout => 'blank'
    end
  end

  def callback
    auth = request.env["omniauth.auth"]
    @user = Hash.new
	@tmp = true

	#1. 로그아웃 
	if session[:user_id].blank?
		@user = User.signin_with_provider(params[:provider], auth["uid"])
		#1-1. 회원가입
		if @user.blank?
			flash[:userdata] = {:provider => auth["provider"], :uid => auth["uid"], :name => auth["info"]["name"], :userid => auth["info"]["email"], :password => '', :userpic => '', :fuid => auth["uid"], :tuid => nil,:fbauth => auth["credentials"]["token"], :local => nil, :gender => auth["extra"]["raw_info"]["gender"]}
			#redirect_to "/signup"
			redirect_to "/signup/step1"
		#1-2. 로그인
		else
			session[:user_id] = @user.userid
			flash[:notice] = "#{@user.name}님, 환영합니다~"
			#redirect_to "/home"
			if session[:returnurl]
        redirect_to session[:returnurl]
        session[:returnurl] = nil
      else
        redirect_to "/home"
      end
		    Notification.LoginCheck(session[:user_id])
		end
	#2. 로그인
	else
		#2-1. 정보수정
        @user = User.info(session[:user_id])
        if auth[:provider] == 'facebook'
          @user.fuid = auth["uid"]
          @user.fbauth = auth["credentials"]["token"]
          flash[:notice] = "Facebook 계정이 연결되었습니다."
        elsif auth[:provider] == 'twitter'
          @user.tuid = auth["uid"]
					@user.tauth = auth['credentials']['token']
					@user.tsecret = auth['credentials']['secret']
          flash[:notice] = "Twitter 계정이 연결되었습니다."
        end          

        @user.save
        session[:user_id] = @user.userid
        
        flash[:notice] = "Facebook 계정이 연결되었습니다."
        redirect_to '/user/edit/sns'
	end

  end
  def signout
    session[:user_id] = nil
    flash[:notice] = "로그아웃 되었습니다."
	#redirect_to "/home"
	redirect_to "/"
  end

  def update
    if session[:user_id]		
      @user = User.info(session[:user_id])
      picdata = User.getProfilePictureset(@user.userid)
      @userpic = ""
      @userpic << "<span class=\"facebook\" for=\"facebook\" addr=\"#{picdata[:facebook]}\">f</span>" if picdata[:facebook]
      @userpic << "<span class=\"twitter\" for=\"twitter\" addr=\"#{picdata[:twitter]}\">t</span>" if picdata[:twitter]
      ##@userpic << "<span class=\"btn new\" addr=\"new\"><i class=\"icon-pencil\"></i></span>"
      #@userpic << "<span class=\"btn hooful\" for=\"hooful\" addr=\"http://d3o755op057jl1.cloudfront.net/hooful/edit_image.png\"><i class=\"icon-remove\"></i></span>"
    end
  end

  def update_certification
    if request.post?
      session[:user_id] = params[:userid]
      @user = User.info(params[:userid])
      @user.job = params[:job]
      @user.members = params[:members]
      @user.certpic = params[:certpicname]
      if @user.save
        session[:user_id] = @user.userid
        flash[:update_txt] = "소속 재인증이 신청되었습니다."
        redirect_to '/user/edit'
      end
	  end
    if session[:user_id]		
      @user = User.info(session[:user_id])
    end
  end

  def update_password
    if session[:user_id]		
      @user = User.info(session[:user_id])
    end
  end

  def update_sns
    if session[:user_id]		
      @user = User.info(session[:user_id])
    end
  end

  def update_notification
    if session[:user_id]		
      @user = User.info(session[:user_id])
      @notify = ActiveSupport::JSON.decode(@user.noti)
    end
  end

  def update_category
    if session[:user_id]		
      @user = User.info(session[:user_id])
      @category = (@user.category == nil) ? '{"paragliding":"0","skydiving":"0","firing":"0","rockclimbing":"0","bungeejump":"0","waterskis":"0","jetskis":"0","kayak":"0","scubadiving":"0","camping":"0"}' : @user.category
      @uCate = ActiveSupport::JSON.decode(@category)
      @category_intro_icon = Interest.getIconRegister(@uCate)
    end
  end

  def ticket
    @user = User.info(session[:user_id])
    @tcnt = TicketSold.ticketCount(session[:user_id])
    @ticket = TicketSold.listGroupMeet(session[:user_id])
  end

  def ticket_old
    @user = User.info(session[:user_id])
    @tcnt = TicketSold.ticketCount(session[:user_id])
    @ticket = TicketSold.oldlistTicket(session[:user_id])
  end

  def ticket_detail
    @user = User.info(session[:user_id])
    @ticket = TicketSold.odetailTicket(params[:tid])
    @payinfo = Payhistory.loadPay(@ticket[0]["payId"])
  end

  def ticket_cancel
    @user = User.info(session[:user_id])
    @ticket = TicketSold.odetailTicket(params[:tid])
  end

  def ticket_reserved
    @user = User.info(session[:user_id])
    @tcnt = TicketSold.ticketCount(session[:user_id])
    @ticket = TicketSold.reservedListTicket(session[:user_id])
  end

  def ticket_print
    @user = User.info(session[:user_id])
    @ticket = TicketSold.detailTicket(params[:tid])
    render :layout => 'popup'
  end

  def ticket_cancel_create
    TicketSold.changeOnlyState(params[:tCode], 1, 0)
    redirect_to '/user/ticket/'+params[:tsId]
  end

  def order
    @user = User.info(session[:user_id])
    @ticket = TicketSold.orderListTicket(session[:user_id])
  end

  def order_detail
    @chkState = true
    @user = User.info(session[:user_id])
    @ticket = TicketSold.orderDetailTicket(session[:user_id], params[:orderid])
    @payinfo = Payhistory.loadPay(@ticket[0][:payId])
  end

  def order_detail_cancel
    @cTicket = TicketSold.cancelTicket(params[:orderid], params[:tid])
    if @cTicket["ReplyCode"].to_s == "0000"
      TicketRefund.create_refund(params)
      redirect_to '/user/order'
    else
      redirect_to '/user/order/'+params[:orderid]
    end
  end

  def update_info
    @user = User.info(params[:userid])
    case params[:updateType]
      when "info"
        case params[:userpicCopy]
          when "/userpic/noimage.png"
            @user.userpic = "hooful"
          when "hooful"
            @user.userpic = "hooful"
          when "twitter"
            @user.userpic = "twitter"
          when "facebook"
            @user.userpic = "facebook"
        end

        @user.userpicname = params[:userpicname] if params[:userpicname]
        @user.name = params[:name] if params[:name]
        @user.sex = params[:userSex]
        @user.local = params[:local] if params[:local]
        @user.job = params[:job] if params[:job]
        @user.members = params[:members] if params[:members]
        @user.phone = params[:phone] if params[:phone]
        @user.coverpic = params[:mPicturename] if params[:mPicturename]
        @user.certpic = params[:certpicname] if params[:certpicname]
        @user.comment = params[:comment] if params[:comment]
        @user.save
        session[:user_id] = @user.userid
        flash[:update_txt] = "정보가 수정되었습니다."
        redirect_to '/user/edit'
      when "category"
        flash[:update_txt] = params[:update_txt]
        redirect_to '/user/edit/category'
      when "password"
        if @user.password != Digest::SHA2.hexdigest(params[:old_password])
          flash[:update_txt] = "비밀번호가 일치하지 않습니다."
          redirect_to '/user/edit/password'
        else
          @user.password = Digest::SHA2.hexdigest(params[:password])
          @user.save
          session[:user_id] = @user.userid
        flash[:update_txt] = "비밀번호가 변경되었습니다."
          redirect_to '/user/edit/password'
        end
      when "sns"
        flash[:update_txt] = "SNS 연동이 변경되었습니다."
        redirect_to '/user/edit/sns'
      when "notification"
        result = '{"partice_host":' + ((params[:partice_host].nil?) ? 'false' : 'true') + ','
        result << '"partice_participants":' + ((params[:partice_participants].nil?) ? 'false' : 'true') + ','
        result << '"hoo_host":' + ((params[:hoo_host].nil?) ? 'false' : 'true') + ','
        result << '"hoo_participants":' + ((params[:hoo_participants].nil?) ? 'false' : 'true') + ','
        result << '"hootalk_host":' + ((params[:hootalk_host].nil?) ? 'false' : 'true') + ','
        result << '"hootalk_participants":' + ((params[:hootalk_participants].nil?) ? 'false' : 'true') + ','
        result << '"nday_host":' + ((params[:nday_host].nil?) ? 'false' : 'true') + ','
        result << '"nday_participants":' + ((params[:nday_participants].nil?) ? 'false' : 'true') + ','
        result << '"dday_host":' + ((params[:dday_host].nil?) ? 'false' : 'true') + ','
        result << '"dday_participants":' + ((params[:dday_participants].nil?) ? 'false' : 'true') + '}'
        @user.noti = result
        @user.save
        session[:user_id] = @user.userid
        flash[:update_txt] = "알림 설정이 수정되었습니다."
        redirect_to '/user/edit/notification'
    end
  end

  def reset_password
    if params[:userid] and request.post?
  		user = User.find_valid_user(params[:userid],"","reset_password")
  		if user[:valid]
  			encaped = Home.getEncapedCode('pwdchange',user.userid,user.created_at)
  			url = 'https://www.hooful.com/user/change_password?code=' + encaped	
  			UserMailer.change_password(user, url)#.deliver
  		end
  		flash[:notice] = user[:notice]
  		redirect_to "/signin"
  	end
  end

  def change_password
    if params[:code]
      @encaped = Home.checkEncapeCode(params[:code],'pwdchange')
    elsif params[:password] and request.post?
      user = User.find_valid_user(params[:encap_userid],params[:password],"change_password")
      flash[:notice] = user[:notice]
      redirect_to user[:redirect]
      #redirect_to :controller => "users", :action => "signin"
    else
      flash[:notice] = "잘못된 접근입니다."
      redirect_to :controller=>'home', :action=>'dindex'
    end
  end

end
