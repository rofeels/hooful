#encoding: UTF-8
class CommunityTalkController < ApplicationController
  respond_to :json
  
  def index
    @cTalk = []
    @rTalk = CommunityTalk.list(params)
    @rTalk.each do |talk|
      half_type = (talk.created_at.strftime("%P") == "am") ? "오전" : "오후"
      talk["picture"] = S3ADDR + "userpic/noimage.png" unless talk["picture"]
      talk["name"] = "비회원" unless talk["name"]
      talk["created"] = talk.created_at.strftime("%m-%d #{half_type} %l:%M")
      @cTalk << talk
    end
	  respond_with @cTalk
  end

  def show
    respond_with Group.where(:_id => params[:id])
  end

  def create
    if params[:type] == "sendTalk"
      @userinfo = User.where(:userid => params[:mUserid]).first
      @group_talk = CommunityTalk.sendTalk(params[:type], params[:message], @userinfo, params[:mCode])
      respond_with @group_talk
	  end
  end

end