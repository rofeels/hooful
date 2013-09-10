#encoding: UTF-8
include ActionView::Helpers::DateHelper#time_ago_in_words
class GuestbookController < ApplicationController
  respond_to :json
  TALK_LIMIT = 5
  def index
	@category_to_s = Hash.new
	Interest.all.each do |cat|
		@category_to_s[cat.code] = cat.name
	end
	if params[:lastTalk]
		@ehootalk = Guestbook.where(:gHostid => params[:gHostid], :_id.lt =>params[:lastTalk]).desc(:created_at)
	else
		@ehootalk = Guestbook.where(:gHostid => params[:gHostid]).desc(:created_at)
	end
	@hootalk = []
	@ehootalk.limit(TALK_LIMIT).each do |hootalk|
		hootalk_info = hootalk.userinfo
		mtmp = Hash.new
		mtmp["gid"] = hootalk._id
		mtmp["gHostid"] = hootalk.gHostid
		mtmp["mCategory"] = hootalk.mCategory
		mtmp["mCatName"] = @category_to_s[hootalk.mCategory]
		mtmp["mTitle"] = hootalk.mTitle
		mtmp["mCode"] = hootalk.mCode
		mtmp["gMsg"] = hootalk.gMsg
		mtmp["created_at"] = "#{time_ago_in_words(hootalk.created_at)}"
		mtmp["userid"] = hootalk_info.userid
		mtmp["link"] = Home.encode(hootalk_info.userid)
		mtmp["picture"] = hootalk_info.picture
		mtmp["name"] = hootalk_info.name
		@hootalk << mtmp
	end
	if @ehootalk.count > TALK_LIMIT
		mtmp = Hash.new
		mtmp["prev"] = @ehootalk.count
		@hootalk << mtmp
	end
    respond_with @hootalk
  end

  def show
  end

  def create
	@category_to_s = Hash.new
	Interest.all.each do |cat|
		@category_to_s[cat.code] = cat.name
	end
	Guestbook.create(:gHostid => params[:gHostid],:mCode => params[:mCode],:mCode => params[:mCode],:mCategory => params[:mCategory],:mTitle => params[:mTitle],:gMsg => params[:gMsg],:gUserid => params[:gUserid])
	#Notification.delay.send('hootalk_host', params[:rUserid], params[:gHostid])
	#Notification.delay.send('hootalk_participants', params[:rUserid], params[:gHostid])
	#Notification.delay.send('hootalk_writer', params[:rUserid], params[:gHostid])
	Notification.send("guestbook_write", params[:gUserid], params[:gHostid], params[:gMsg])

	if params[:firstTalk]
		@ehootalk = Guestbook.where(:gHostid => params[:gHostid], :_id.gt =>params[:firstTalk]).desc(:created_at)
	else
		@ehootalk = Guestbook.where(:gHostid => params[:gHostid]).desc(:created_at).limit(TALK_LIMIT)
	end
	@hootalk = []
	@ehootalk.each do |hootalk|
		mtmp = Hash.new
		hootalk_info = hootalk.userinfo
		mtmp["gid"] = hootalk._id
		mtmp["gHostid"] = hootalk.gHostid
		mtmp["mCategory"] = hootalk.mCategory
		mtmp["mCatName"] = @category_to_s[hootalk.mCategory]
		mtmp["mTitle"] = hootalk.mTitle
		mtmp["mCode"] = hootalk.mCode
		mtmp["gMsg"] = hootalk.gMsg
		mtmp["created_at"] = "#{time_ago_in_words(hootalk.created_at)}"
		mtmp["userid"] = hootalk_info.userid
		mtmp["link"] = Home.encode(hootalk_info.userid)
		mtmp["picture"] = hootalk_info.picture
		mtmp["name"] = hootalk_info.name
		@hootalk << mtmp
	end
	render :json => @hootalk.to_json
  end

end