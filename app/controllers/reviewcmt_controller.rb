#encoding: UTF-8
class ReviewcmtController < ApplicationController
  respond_to :json
  TALK_LIMIT = 5
  def index
	if params[:firstTalk]
		@ehootalk = Reviewcmt.where(:rCode => params[:rCode], :_id.lt =>params[:firstTalk]).desc(:created_at)
	else
		@ehootalk = Reviewcmt.where(:rCode => params[:rCode]).desc(:created_at)
	end
	@hootalk = []
	if @ehootalk.count > TALK_LIMIT
		mtmp = Hash.new
		mtmp["prev"] = @ehootalk.count-TALK_LIMIT
		@hootalk << mtmp
	end
	@ehootalk = @ehootalk.limit(TALK_LIMIT).reverse
	@ehootalk.each do |hootalk|
		hootalk_info = hootalk.userinfo
		mtmp = Hash.new
		mtmp["rid"] = hootalk._id
		mtmp["rCode"] = hootalk.rCode
		mtmp["rMsg"] = hootalk.rMsg
		mtmp["created_at"] = "#{time_ago_in_words(hootalk.created_at)}"
		mtmp["rUserid"] = hootalk.rUserid
		mtmp["userid"] = hootalk_info.userid
		mtmp["link"] = Home.encode(hootalk_info.userid)
		mtmp["picture"] = hootalk_info.picture
		mtmp["name"] = hootalk_info.name
		@hootalk << mtmp
	end
    render :json => @hootalk
  end

  def show
  end

  def create
	Reviewcmt.create(:rCode => params[:rCode],:rMsg => params[:rMsg],:rUserid => params[:rUserid])
  Review.incCmt(params[:rCode]) if params[:rCode] != ""
	#Notification.delay.send('hootalk_host', params[:rUserid], params[:rCode])
	#Notification.delay.send('hootalk_participants', params[:rUserid], params[:rCode])
	#Notification.delay.send('hootalk_writer', params[:rUserid], params[:rCode])
	Notification.send("review_cmt", params[:rUserid], params[:rCode], params[:rMsg])
	if params[:lastTalk]
		@ehootalk = Reviewcmt.where(:rCode => params[:rCode], :_id.gt =>params[:lastTalk])
	else
		@ehootalk = Reviewcmt.where(:rCode => params[:rCode]).desc(:created_at).limit(TALK_LIMIT).reverse
	end
	@hootalk = []
	@ehootalk.each do |hootalk|
		mtmp = Hash.new
		hootalk_info = hootalk.userinfo
		mtmp["rid"] = hootalk._id
		mtmp["rCode"] = hootalk.rCode
		mtmp["rMsg"] = hootalk.rMsg
		mtmp["created_at"] = "#{time_ago_in_words(hootalk.created_at)}"
		mtmp["rUserid"] = hootalk.rUserid
		mtmp["userid"] = hootalk_info.userid
		mtmp["link"] = Home.encode(hootalk_info.userid)
		mtmp["picture"] = hootalk_info.picture
		mtmp["name"] = hootalk_info.name
		@hootalk << mtmp
	end
	render :json => @hootalk.to_json
  end

end