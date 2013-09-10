#encoding: utf-8
require 'net/http'

class MeetGroupTalk
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :gType, type: String
  field :gMessage, type: String
  field :picture, type: String
  field :userid, type: String
  field :name, type: String

  GroupText = Hash.new
  GroupText[:enter] = "{subject}님이 입장하셨습니다."
  GroupText[:leave] = "{subject}님이 퇴장하셨습니다."

  def self.sendTalk(type, msg, user, mcode,push)
	case type
	  when "enter" then
		  message = GroupText[:enter]
	  	  message = message.gsub(/\{subject}+/, "<a href='/users/#{user.userid}'>#{user.name}</a>")
		  MeetGroupTalk.push(user,type,"mem",mcode) if push == 1#socket push
	      MeetGroupTalk.create(:gType => type, :mCode => mcode,:gMessage => message,:picture => user.picture, :userid => user.userid, :name => user.name)
	  when "leave" then
		  message = GroupText[:leave]
	  	  message = message.gsub(/\{subject}+/, "<a href='/users/#{user.userid}'>#{user.name}</a>")
		  MeetGroupTalk.push(user,type,"mem",mcode) if push == 1#socket push
	      MeetGroupTalk.create(:gType => type, :mCode => mcode,:gMessage => message,:picture => user.picture, :userid => user.userid, :name => user.name)
	  when "msg" then
		  #Notification.send("meet_group_new_msg", user.userid, mcode,"")
		  MeetGroupTalk.push(user,type,"chat",mcode) if push == 1#socket push
	      MeetGroupTalk.create(:gType => type, :mCode => mcode,:gMessage => msg,:picture => user.picture, :userid => user.userid, :name => user.name)
	  else
	end
  end
  def self.push(sender,msg,type, mcode)
	  @groupmembers = TicketSold.where(:mCode => mcode, :tState.ne => 7)
	  @groupmembers.each do |member|
		  if msg != "leave" or sender != member.mUserid
			  url = "http://hooful.com:6530/push/group#{type}/#{mcode}/#{member.mUserid}"
			  res = Net::HTTP.post_form(URI.parse(URI.encode(url)),{})

			  # 200 implies successfully sent.
			  # There is nothing we can do if the targe user is not online(404)
			  # For any other error, raise Exception
			  unless ["200", "404"].include? res.code
				#raise Exception.new("Error: #{res.code}")
			  end
			end		
	  end
  end
end