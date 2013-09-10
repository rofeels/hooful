# coding : utf-8
#encoding: UTF-8
include ActionView::Helpers::DateHelper#time_ago_in_words
class ReviewController < ApplicationController
	respond_to :json
	before_filter :authorize_write, :only => [:rwrite]
	before_filter :authorize_update, :only => [:update]
	REVIEW_LIMIT = 2
	TEXT_LIMIT = 170

  def authorize_write
    if ! session[:user_id]
          flash[:notice] = "접근 권한이 없습니다."
          redirect_to "/r"
    end
  end
  def authorize_update
    @review = Review.get_review_detail(params[:rCode])
    if @review.nil? or @review.mWriter != session[:user_id]
          flash[:notice] = "접근 권한이 없습니다."
          redirect_to "/home"
    end
  end

  def rwrite
    if params[:userid] and session[:user_id].nil?
      session[:user_id] = params[:userid]
    end
  end

  def create
	@create_review = Review.create_review(params)
	if @create_review == true
		@user = User.info(session[:user_id])
		HardWorker.tweet(params,@user,'meet') if params["tuid"]== '1'
		HardWorker.fbfeed(params,@user,'meet') if params["fuid"]=='1'
	elsif @create_review == false
		#flash[:notice] = "오류가 발생했습니다. 후기가 작성되지 않았습니다."
		#redirect_to :controller => 'review', :action => 'index'
	else
		#flash[:notice] = "작성된 내용이 부족합니다. 후기가 작성되지 않았습니다."
		#redirect_to :back
	end
  if params[:mWriter] and session[:user_id].nil?
    session[:user_id] = params[:mWriter]
  end
	render :json => [{:result => @create_review.to_json}]
  end

  def show
    params[:rCode] = params[:rid]
    params[:rUserid] = session[:user_id]
    review = Review.get_review_detail(params[:rid])
    writer = User.info(review.mWriter)
    @comment = Reviewcmt.loadCmt(params)
		@review = Hash.new
		
		@review["rid"] = review._id.to_s
		@review["rcode"] = review.rCode
		 if review.mTitle
			@review["title"] = review.mTitle 
		else
			@review["title"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
		end
		@review["review_summary"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
		@review["review"] = review.mReview
		@review["review_picture"] = review.mPicturename
		
		half_type = (review.created_at.strftime("%P") == "am") ? "am" : "pm"
		@review["created_at"] = review.created_at.strftime("%Y. %m. %d #{half_type}. %l:%M")
		@review["reviewcmt"] = Reviewcmt.cmtcount(review._id)
		@review["userid"] = writer.userid
		@review["link"] = Home.encode(writer.userid)
		@review["picture"] = writer.picture
		@review["name"] = writer.name
		@review["members"] = writer.members
		
		meetinfo = Meet.where(:mCode => review.mCode).first
		@review["meet"] = meetinfo.mCode
		@review["meettitle"] = meetinfo.mTitle
		@review["meetpicture"] = meetinfo.mPicture
		@review["meethost"] = meetinfo.mHost
		@review["meetprice"] = meetinfo.card_price

		hostinfo = User.info(meetinfo.mHost)
		@review["host_picture"] = hostinfo.picture
		@review["host_link"] = hostinfo.link
		@review["host_name"] = hostinfo.name
		@review["host_members"] = hostinfo.members


		@review["category"] = meetinfo.mCategory
		@review["categoryname"] = Interest.where(:code => @review["category"]).first.name
  end

=begin
  def show

    respond_to do |format|
	  format.html
	  format.json  {
		review = Review.get_review_detail(params[:id])
		writer = User.info(review.mWriter)
		@review = Hash.new
		
		@review["rid"] = review._id.to_s
		@review["rcode"] = review.rCode
		 if review.mTitle
			@review["title"] = review.mTitle 
		else
			@review["title"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
		end
		@review["review_summary"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
		@review["review"] = review.mReview
		
		half_type = (review.created_at.strftime("%P") == "am") ? "am" : "pm"
		@review["created_at"] = review.created_at.strftime("%Y. %m. %d #{half_type}. %l:%M")
		@review["reviewcmt"] = Reviewcmt.cmtcount(review._id)
		@review["userid"] = writer.userid
		@review["link"] = Home.encode(writer.userid)
		@review["picture"] = writer.picture
		@review["name"] = writer.name
		@review["members"] = writer.members
		
		meetinfo = Meet.where(:mCode => review.mCode).first
		@review["meet"] = meetinfo.mCode
		@review["meettitle"] = meetinfo.mTitle
		@review["meetpicture"] = meetinfo.mPicture
		@review["meethost"] = meetinfo.mHost
		@review["meetprice"] = meetinfo.card_price

		hostinfo = User.info(meetinfo.mHost)
		@review["host_picture"] = hostinfo.picture
		@review["host_link"] = hostinfo.link
		@review["host_name"] = hostinfo.name
		@review["host_members"] = hostinfo.members


		@review["category"] = meetinfo.mCategory
		@review["categoryname"] = Interest.where(:code => @review["category"]).first.name

		respond_with @review
	  }
    end
  end
=end

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
    @sreview = Review.all.desc(:created_at)
    @review = []
		@sreview.each do |review|
			#writer = User.info(review.mWriter)
			rtmp = Hash.new
			rtmp["rid"] = review._id
			rtmp["rcode"] = review.rCode
			
			 if review.mTitle
				rtmp["title"] = review.mTitle 
			else
				rtmp["title"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
			end
			rtmp["review"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
      rtmp["greview"] = rtmp["review"]
			rtmp["greview"] = "#{rtmp['review'][0..TEXT_LIMIT]}..."  if rtmp["review"].length > TEXT_LIMIT
		
			rtmp["created_at"] = "#{time_ago_in_words(review.created_at)}"
			rtmp["reviewcmt"] = review.uCmtcnt
      rtmp["likecnt"] = review.uHoo
			#rtmp["userid"] = writer.userid
			#rtmp["link"] = Home.encode(writer.userid)
			#rtmp["members"] = writer.members
			#rtmp["picture"] = writer.picture
			#rtmp["name"] = writer.name
			@review << rtmp
		end
		if @sreview.count > REVIEW_LIMIT
			rtmp = Hash.new
			rtmp["next"] = @sreview.count - REVIEW_LIMIT
			@review << rtmp
		end
  end

=begin
  def index
	
	if params[:category]
		category = Meet.where(mCategory: params[:category])

		if params[:lastReview]
			@sreview =  Review.where(:mCode.in => category.map(&:mCode),:_id.lt =>params[:lastReview])
		else
			@sreview = Review.where(:mCode.in => category.map(&:mCode)).desc(:created_at)
		end
		@review = []
		@sreview.limit(REVIEW_LIMIT).each do |review|
			writer = User.info(review.mWriter)
			rtmp = Hash.new
			rtmp["rid"] = review._id
			rtmp["rcode"] = review.rCode
			
			 if review.mTitle
				rtmp["title"] = review.mTitle 
			else
				rtmp["title"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
			end
			rtmp["review"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
			rtmp["review"] = "#{rtmp['review'][0..TEXT_LIMIT]}..."  if rtmp["review"].length > TEXT_LIMIT
		
			rtmp["created_at"] = "#{time_ago_in_words(review.created_at)}"
			rtmp["reviewcmt"] = Reviewcmt.cmtcount(review._id)
			rtmp["userid"] = writer.userid
			rtmp["link"] = Home.encode(writer.userid)
			rtmp["picture"] = writer.picture
			rtmp["members"] = writer.members
			rtmp["name"] = writer.name
			@review << rtmp
		end
		if @sreview.count > REVIEW_LIMIT
			rtmp = Hash.new
			rtmp["next"] = @sreview.count - REVIEW_LIMIT
			@review << rtmp
		end
	else
		hosted = Meet.where(mHost: params[:mHost])

		if params[:lastReview]
			@sreview =  Review.where(:mCode.in => hosted.map(&:mCode),:_id.lt =>params[:lastReview])
		else
			@sreview = Review.where(:mCode.in => hosted.map(&:mCode)).desc(:created_at)
		end
		@review = []
		@sreview.limit(REVIEW_LIMIT).each do |review|
			writer = User.info(review.mWriter)
			rtmp = Hash.new
			rtmp["rid"] = review._id
			rtmp["rcode"] = review.rCode
			
			 if review.mTitle
				rtmp["title"] = review.mTitle 
			else
				rtmp["title"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
			end
			rtmp["review"] = review.mReview.gsub(%r{</?[^>]+?>}, '')
			rtmp["review"] = "#{rtmp['review'][0..TEXT_LIMIT]}..."  if rtmp["review"].length > TEXT_LIMIT
		
			rtmp["created_at"] = "#{time_ago_in_words(review.created_at)}"
			rtmp["reviewcmt"] = Reviewcmt.cmtcount(review._id)
			rtmp["userid"] = writer.userid
			rtmp["link"] = Home.encode(writer.userid)
			rtmp["members"] = writer.members
			rtmp["picture"] = writer.picture
			rtmp["name"] = writer.name
			@review << rtmp
		end
		if @sreview.count > REVIEW_LIMIT
			rtmp = Hash.new
			rtmp["next"] = @sreview.count - REVIEW_LIMIT
			@review << rtmp
		end
	end
	respond_with @review


  end
=end

end
