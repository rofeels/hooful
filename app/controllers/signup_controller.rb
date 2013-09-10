#encoding: utf-8
class SignupController < ApplicationController
  before_filter :authorize, :only => [:step2, :step3, :complete]
  before_filter :fbcheck, :only => [:step1]

  protected
  def authorize
	if request.post?
		@user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => params[:userid]}]).last
		session[:user_id] = @user.userid		
	else
		@user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => session[:user_id]}]).last
	end
   if @user
    else
		session[:user_id] = nil
		flash[:notice] = "로그인 해주시기 바랍니다."
		#redirect_to "/"
    end
  end

  def fbcheck
	if flash[:userdata] or request.post?
    else
		session[:user_id] = nil
		flash[:notice] = "페이스북 연동이 필요합니다."
		#redirect_to "/"
    end
  end

  public
  layout 'signup'
  def index
	  
		@my = User.info(session[:user_id]) if session[:user_id]
	  
    @fb_org = Fbevent.load.ranking
    @fb_org = @fb_org.sort{ |k, v| v["value"]["total"].to_i <=> k["value"]["total"].to_i }
    @rank = @fb_org.index{|x|x["_id"]==@my.userid.to_s}.to_i + 1 if session[:user_id]
  end

  def step1
	@bg = "signup"  
    @userinfo = Hash.new
	@userinfo[:userpicname] = "#{S3ADDR}newhooful/preregist/preregist_profile_200.png"
    if flash[:userdata]
      @userinfo = flash[:userdata]
	  @userinfo[:userpicname] = "http://graph.facebook.com/#{@userinfo[:uid]}/picture?width=200&height=200"
    end
	
	if request.post?
		@user = User.create_user(params)
		if @user.save


			@fb = Hash.new
			@fb[:type] = 0
			@fb[:userid] = @user.userid
			@fb[:fuid] = @user.fuid
			@fb[:feed_id] = ''
			@fb[:friends] = ''
			@fb[:friends_cnt] = ''
			@fb[:point] = 200
			@event = Fbevent.create_event(@fb)

			@fb = Hash.new
			@fb[:type] = -10
			@fb[:userid] = @user.userid
			@fb[:fuid] = @user.fuid
			@fb[:feed_id] = ''
			@fb[:friends] = ''
			@fb[:friends_cnt] = ''
			@fb[:point] = 0

			@event = Fbevent.create_event(@fb)


			session[:user_id] = @user.userid
			redirect_to '/signup/step2'
		else
			flash[:notice] = "가입에 실패하였습니다. 다시 시도해주시기 바랍니다."
			redirect_to '/signup/step1'
		end
  	end
  end

  def step2
	@bg = "signup"  
	#@user = User.info(session[:user_id])
    @category_intro_icon = Interest.getIconRegister(Hash.new)

  end

  def step3
	@bg = "signup"  
	if request.post?
		@user = User.info(params[:userid])
		@user.job = params[:job]
		@user.members = params[:members]
		@user.certpic = params[:certpicname]
		if @user.save
			session[:user_id] = @user.userid
		  redirect_to '/signup/complete'
		end
	  end
  end

  def complete
	@bg = "tutorial"  
	@user = User.info(session[:user_id])
  
  end

  def show
  end
end
