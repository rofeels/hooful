#encoding: UTF-8
class NotificationController < ApplicationController
  before_filter :authorize, :only => [:list]
  respond_to :json

  protected
  def authorize
    user = nil
    user = session[:user_id] if session[:user_id]
		@user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => user}]).last
    if @user
    else
      flash[:notice] = "로그인 해주시기 바랍니다."
      redirect_to "/signin"
    end
  end

  public
  def index
	respond_with Notification.load(params[:userid]) 
  end

  def show
  end

  def create
  	if params[:type] == "check"
		@notification = Notification.check(params[:userid],params[:noticenid]) 
		render :json =>  {:result => @notification}		
  	elsif params[:type] =="add"

		time_now = DateTime.now.strftime('%S.%L')
		if !params[:userid].blank?
			@notification = Notification.load(params[:userid]) 
			@result = Hash.new
			@result[:all] = @notification.count -1
			@result[:uncheck] = @notification.last[0]
			time_later = DateTime.now.strftime('%S.%L')
			render :json => @result.to_json	
		end
  	end
  end

  def list
  end

end