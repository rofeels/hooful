# coding : utf-8
#encoding: UTF-8
include ActionView::Helpers::DateHelper#time_ago_in_words
class HopeController < ApplicationController
	respond_to :json
	before_filter :authorize_write, :only => [:hwrite]
	before_filter :authorize_update, :only => [:update]
	REVIEW_LIMIT = 2
	TEXT_LIMIT = 170

  def authorize_write
    if ! session[:user_id]
          flash[:notice] = "접근 권한이 없습니다."
          redirect_to "/h"
    end
  end
  def authorize_update
    @hope = Hope.get_hope_detail(params[:rCode])
    if @hope.nil? or @hope.mWriter != session[:user_id]
          flash[:notice] = "접근 권한이 없습니다."
          redirect_to "/home"
    end
  end

  def hwrite
    if params[:userid] and session[:user_id].nil?
      session[:user_id] = params[:userid]
    end
  end

  def create
    @create_hope = Hope.create_hope(params)
    if params[:mWriter] and session[:user_id].nil?
      session[:user_id] = params[:mWriter]
    end
    render :json => [{:result => @create_hope.to_json}]
  end

  def show
    params[:rCode] = params[:rid]
    params[:rUserid] = session[:user_id]
    review = Hope.get_hope_detail(params[:rid])
    writer = User.info(review.mWriter)
    @comment = Hopecmt.loadCmt(params)
		@review = Hash.new
		
		@review["rid"] = review._id.to_s
		@review["rcode"] = review.rCode
		 if review.mTitle
			@review["title"] = review.mTitle 
		else
			@review["title"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
		end
		@review["review_summary"] = review.mContent.gsub(%r{</?[^>]+?>}, '')
		@review["review"] = review.mContent
		@review["review_picture"] = review.mPicturename
		@review["when"] = review.mWhen
		@review["where"] = review.mWhere
		@review["what"] = review.mWhat
		
		half_type = (review.created_at.strftime("%P") == "am") ? "am" : "pm"
		@review["created_at"] = review.created_at.strftime("%Y. %m. %d #{half_type}. %l:%M")
		@review["reviewcmt"] = Reviewcmt.cmtcount(review._id)
		@review["userid"] = writer.userid
		@review["link"] = Home.encode(writer.userid)
		@review["picture"] = writer.picture
		@review["name"] = writer.name
		@review["members"] = writer.members
  end

  def update
    if params[:hMethod] == "edit"
      @update_review = Review.update_review(params)
      if @update_review[:result] == true
        @user = User.info(session[:user_id])
        HardWorker.tweet(params,@user,'meet') if params["tuid"]== '1'
        HardWorker.fbfeed(params,@user,'meet') if params["fuid"]=='1'
        params[:id] = @update_review[:_id]
      elsif @update_review[:result] == false
        flash[:notice] = "오류가 발생했습니다. 후기가 수정되지 않았습니다."
        redirect_to :controller => 'review', :action => 'index'
      else
        flash[:notice] = "작성된 내용이 부족합니다. 후기가 수정되지 않았습니다."
        redirect_to :back
      end
	  end
  end

  def index
    @sreview = Hope.all.desc(:created_at)
    @hope = []
		@sreview.each do |review|
			#writer = User.info(review.mWriter)
			rtmp = Hash.new
			rtmp["rid"] = review._id
			rtmp["rcode"] = review.rCode
			
			 if review.mTitle
				rtmp["title"] = review.mTitle 
			else
				rtmp["title"] = review.mContent.gsub(%r{</?[^>]+?>}, '')
			end
			rtmp["review"] = review.mContent.gsub(%r{</?[^>]+?>}, '')
	  	rtmp["when"] = review.mWhen
	  	rtmp["where"] = review.mWhere
	  	rtmp["what"] = review.mWhat
      rtmp["greview"] = rtmp["review"]
			rtmp["greview"] = "#{rtmp['review'][0..TEXT_LIMIT]}..."  if rtmp["review"].length > TEXT_LIMIT
		
			rtmp["created_at"] = "#{time_ago_in_words(review.created_at)}"
			rtmp["reviewcmt"] = review.uCmtcnt
      rtmp["likecnt"] = review.uHoo
			@hope << rtmp
		end
		if @sreview.count > REVIEW_LIMIT
			rtmp = Hash.new
			rtmp["next"] = @sreview.count - REVIEW_LIMIT
			@hope << rtmp
		end
  end

end
