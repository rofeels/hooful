#encoding: utf-8
require 'net/http'

class CommunityTalk
  include Mongoid::Document
  include Mongoid::Timestamps
  field :gMessage, type: String

  GROUPNUM = 4

  def self.sendTalk(type, msg, user, gid)
	  #CommunityTalk.push(gid)#socket push
    if user
      CommunityTalk.create(:type => type, :gMessage => msg,:picture => user.picture, :userid => user.userid, :name => user.name, :mCode => gid, :date => Time.now.strftime("%Y-%m-%d"))
    else
      CommunityTalk.create(:type => type, :gMessage => msg, :mCode => gid, :date => Time.now.strftime("%Y-%m-%d"))
    end     
  end
  def self.push(gid)
	  url = "http://cafe.hooful.com:6530/push/groupchat/#{member.mUserid}"
    res = Net::HTTP.post_form(URI.parse(URI.encode(url)),{})

    # 200 implies successfully sent.
    # There is nothing we can do if the targe user is not online(404)
    # For any other error, raise Exception
    unless ["200", "404"].include? res.code
    #raise Exception.new("Error: #{res.code}")
    end
  end
  def self.list(params)
    params[:page] ||= 1
    @cTalk = CommunityTalk.where(:mCode => params[:mCode]).desc(:created_at).skip(GROUPNUM * (params[:page].to_i - 1)).limit(GROUPNUM)
    @cTalk
  end
end
