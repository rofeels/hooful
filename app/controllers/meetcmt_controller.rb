#encoding: UTF-8
class MeetcmtController < ApplicationController
  respond_to :json
  TALK_LIMIT = 10
  def index
	if params[:lastTalk]
		@ehootalk = Meetcmt.where(:mCode => params[:mCode], :_id.lt =>params[:lastTalk]).desc(:created_at)
	else
		@ehootalk = Meetcmt.where(mCode: params[:mCode]).desc(:created_at)
	end

	@hootalk = []
	@ehootalk = @ehootalk.limit(TALK_LIMIT)

	userinfo = User.find(:all, :conditions => ["userid IN (?)", @ehootalk.map(&:mUserid)])
	@userinfo = Hash.new
	userinfo.each do |user|
		@userinfo["#{user.userid}"] = Hash.new
		@userinfo["#{user.userid}"]["link"] = Home.encode(user.userid)
		@userinfo["#{user.userid}"]["picture"] = user.picture
		@userinfo["#{user.userid}"]["name"] = user.name
	end
	
	@ehootalk.each do |hootalk|
		mtmp = Hash.new
		mtmp["tid"] = hootalk._id
		mtmp["mCode"] = hootalk.mCode
		mtmp["mMsg"] = hootalk.mMsg
		mtmp["mHost"] = hootalk.mHost
		half_type = (hootalk.created_at.strftime("%P") == "am") ? "오전" : "오후"
		mtmp["created_at"] = hootalk.created_at.strftime("%m월%d일 #{half_type}. %l:%M")
		mtmp["mUserid"] = hootalk.mUserid
		mtmp["link"] = @userinfo["#{hootalk.mUserid}"]["link"] if @userinfo["#{hootalk.mUserid}"]
		mtmp["picture"] = @userinfo["#{hootalk.mUserid}"]["picture"] if @userinfo["#{hootalk.mUserid}"]
		mtmp["name"] = @userinfo["#{hootalk.mUserid}"]["name"] if @userinfo["#{hootalk.mUserid}"]
		@hootalk << mtmp
	end
	if @ehootalk.count > TALK_LIMIT
		mtmp = Hash.new
		mtmp["prev"] = @ehootalk.count-TALK_LIMIT
		@hootalk << mtmp
	end
    respond_with @hootalk
  end

  def show
  end

  def create
	Meetcmt.create(:mCode => params[:mCode],:mHost => params[:mHost],:mMsg => params[:mMsg],:mUserid => params[:mUserid])
  Meet.incCmt(params[:mCode])
	if params[:firstTalk]
		@ehootalk = Meetcmt.where(:mCode => params[:mCode], :_id.gt =>params[:firstTalk])
	else
		@ehootalk = Meetcmt.where(:mCode => params[:mCode]).asc(:created_at).limit(TALK_LIMIT)
	end
	@hootalk = []
	@ehootalk.reverse.each do |hootalk|
		mtmp = Hash.new
		hootalk_info = hootalk.userinfo
		mtmp["tid"] = hootalk._id
		mtmp["mCode"] = hootalk.mCode
		mtmp["mMsg"] = hootalk.mMsg
		mtmp["mHost"] = hootalk.mHost
		half_type = (hootalk.created_at.strftime("%P") == "am") ? "오전" : "오후"
		mtmp["created_at"] = hootalk.created_at.strftime("%m월%d일 #{half_type}. %l:%M")
		mtmp["mUserid"] = hootalk_info.userid
		mtmp["link"] = Home.encode(hootalk_info.userid)
		mtmp["picture"] = hootalk_info.picture
		mtmp["name"] = hootalk_info.name
		@hootalk << mtmp
	end
	render :json => @hootalk.to_json
  end

end