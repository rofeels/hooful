#encoding: UTF-8
class GroupTalkController < ApplicationController
  respond_to :json
  TALK_LIMIT = 10
  
  def index
    if params[:type] =="search"
		@groups = []
		groupinfo = Group.find(params[:id])
		members = GroupMember.where(:group_id => params[:id])
		@members = []
		@members[0] = []
		members.each do |member|
			uinfo = User.info(member.mUserid)
			mtmp = Hash.new
			mtmp[:_id] = member._id
			mtmp[:picture] = uinfo.picture
			mtmp[:userid] = uinfo.userid
			mtmp[:link] = Home.encode(uinfo.userid)
			mtmp[:name] = uinfo.name
			mtmp[:members] = uinfo.members

			mtmp[:pay] = 0
			mtmp[:reservation] = 0
			mtmp[:host] = 0

			mtmp[:host] = 1 if groupinfo.gHost ==uinfo.userid

			if mtmp[:name].match(/#{params[:keyword]}/) or mtmp[:userid].match(/#{params[:keyword]}/) or params[:keyword].blank?

				userticket= TicketSold.where(:mCode => groupinfo.mCode, :mUserid => mtmp[:userid], :tState.ne => 7)
				mtmp[:pay] = 1 if userticket.count > 0
				mtmp[:reservation] = 1 if userticket.any_of(:tState => 5).count > 0
				@members[0] << mtmp
			end
		end
		@groups << @members
	elsif params[:type] =="members"
		@groups = []
		members = GroupMember.where(:group_id => params[:id])
		groupinfo = Group.find(params[:id])
		@members = []
		@members[0] = []
		members.each do |member|
			uinfo = User.info(member.mUserid)
			mtmp = Hash.new
			mtmp[:_id] = member._id
			mtmp[:picture] = uinfo.picture
			mtmp[:userid] = uinfo.userid
			mtmp[:link] = Home.encode(uinfo.userid)
			mtmp[:name] = uinfo.name
			mtmp[:members] = uinfo.members
			mtmp[:pay] = 0
			mtmp[:reservation] = 0
			mtmp[:host] = 0

			mtmp[:host] = 1 if groupinfo.gHost ==uinfo.userid

			if mtmp[:name].match(/#{params[:keyword]}/) or mtmp[:userid].match(/#{params[:keyword]}/) or params[:keyword].blank?

				userticket= TicketSold.where(:mCode => groupinfo.mCode, :mUserid => mtmp[:userid], :tState.ne => 7)
				mtmp[:pay] = 1 if userticket.count > 0
				mtmp[:reservation] = 1 if userticket.any_of(:tState => 5).count > 0
				@members[0] << mtmp
			end
		end

		if params[:lastTalk]
			talks= GroupTalk.where(:group_id => params[:id], :_id.gt =>params[:lastTalk]).desc(:created_at)
		else
			talks= GroupTalk.where(:group_id => params[:id]).desc(:created_at)
		end

		@talks = []
		@talks[0] = []
		talks.reverse.each do |talk|
			ttmp = Hash.new
			ttmp[:picture] = talk.picture
			ttmp[:userid] = talk.userid
			ttmp[:link] = Home.encode(talk.userid)
			ttmp[:sex] = User.where(:userid => talk.userid).first.sex
			ttmp[:name] = talk.name
			ttmp[:msg] = talk.gMessage
			ttmp[:type] = talk.gType
			ttmp[:tid] = talk._id
			half_type = (talk.created_at.strftime("%P") == "am") ? "오전" : "오후"
			ttmp[:created] = talk.created_at.strftime("%m-%d #{half_type} %l:%M")

			@talks[0] << ttmp
		end

 		@groups << @members
		@groups << @talks

	elsif params[:type] =="talks"
		@groups = []

		if params[:firstTalk]
			talks= GroupTalk.where(:group_id => params[:id], :_id.lt =>params[:firstTalk]).not_in(:gType => ["enter", "leave"]).desc(:created_at)
		else
			talks= GroupTalk.where(:group_id => params[:id]).not_in(:gType => ["enter", "leave"]).desc(:created_at)
		end

		@talks = []
		@talks[0] = []
		if talks.count > TALK_LIMIT
			ttmp = Hash.new
			ttmp["prev"] = talks.count-TALK_LIMIT
			@talks[0]  << ttmp
		end
		talklimit = talks.limit(TALK_LIMIT)		
		GroupTalk.where(:group_id => params[:id], :_id.lte => talklimit.first._id, :_id.gte => talklimit.reverse.first._id).each do |talk|
			ttmp = Hash.new
			ttmp[:picture] = talk.picture
			ttmp[:userid] = talk.userid
			ttmp[:link] = Home.encode(talk.userid)
			ttmp[:sex] = User.where(:userid => talk.userid).first.sex
			ttmp[:name] = talk.name
			ttmp[:msg] = talk.gMessage
			ttmp[:type] = talk.gType
			ttmp[:tid] = talk._id
			half_type = (talk.created_at.strftime("%P") == "am") ? "오전" : "오후"
			ttmp[:created] = talk.created_at.strftime("%m-%d #{half_type} %l:%M")

			@talks[0] << ttmp
		end
		@members = []
		@members[0] = []
 		@groups << @members
		@groups << @talks

	else
		@groups = []
		@match = Hash.new
		groupinfo = Group.find(params[:id])
		members = GroupMember.where(:group_id => params[:id])
		@members = []
		@members[0] = []
		members.each do |member|
			uinfo = User.info(member.mUserid)
			mtmp = Hash.new
			mtmp[:_id] = member._id
			mtmp[:picture] = uinfo.picture
			mtmp[:link] = Home.encode(uinfo.userid)
			mtmp[:userid] = uinfo.userid
			mtmp[:name] = uinfo.name
			mtmp[:members] = uinfo.members
			mtmp[:pay] = 0
			mtmp[:reservation] = 0
			mtmp[:host] = 0

			mtmp[:host] = 1 if groupinfo.gHost ==uinfo.userid
			userticket= TicketSold.where(:mCode => groupinfo.mCode, :mUserid => mtmp[:userid], :tState.ne => 7)
			mtmp[:pay] = 1 if userticket.count > 0
			mtmp[:reservation] = 1 if userticket.any_of(:tState => 5).count > 0

			@match[mtmp[:_id]] = mtmp
			@members[0] << mtmp
		end


		talks= GroupTalk.where(:group_id => params[:id]).not_in(:gType => ["enter", "leave"]).desc(:created_at)
		@talks = []
		@talks[0] = []

		talklimit = talks.limit(TALK_LIMIT)
		if talklimit.count > 0
			if talks.count > TALK_LIMIT
				ttmp = Hash.new
				ttmp["prev"] = talks.count-TALK_LIMIT
				@talks[0]  << ttmp
			end
			GroupTalk.where(:group_id => params[:id], :_id.lte => talklimit.first._id, :_id.gte => talklimit.reverse.first._id).each do |talk|
				ttmp = Hash.new
				ttmp[:picture] = talk.picture
				ttmp[:userid] = talk.userid
				ttmp[:link] = Home.encode(talk.userid)
				ttmp[:name] = talk.name
				ttmp[:sex] = User.where(:userid => talk.userid).first.sex
				ttmp[:msg] = talk.gMessage
				ttmp[:type] = talk.gType
				ttmp[:tid] = talk._id
				half_type = (talk.created_at.strftime("%P") == "am") ? "오전" : "오후"
				ttmp[:created] = talk.created_at.strftime("%m-%d #{half_type} %l:%M")

				@talks[0] << ttmp
			end
		end
		@groups << @members
		@groups << @talks
	end
	respond_with @groups
  end

  def show
    respond_with Group.all
  end

  def create
	if params[:type] == "send"
		@group = Group.find(params[:id])
		@group_member = GroupMember.where(:mUserid => params[:mUserid], :group_id => params[:id]).first
		@userinfo = User.where(:userid => params[:mUserid]).first
		@group_talk = GroupTalk.sendTalk("msg",params[:message], @userinfo,params[:id],1)
		@group.group_talks << @group_talk
		@group_member.group_talks << @group_talk
    end
		@groups = []

		if params[:lastTalk]
			talks= GroupTalk.where(:group_id => params[:id], :_id.gt =>params[:lastTalk]).desc(:created_at)
		else
			talks= GroupTalk.where(:group_id => params[:id]).desc(:created_at)
		end

		@talks = []
		@talks[0] = []
		talks.reverse.each do |talk|
			ttmp = Hash.new
			ttmp[:picture] = talk.picture
			ttmp[:userid] = talk.userid
			ttmp[:link] = Home.encode(talk.userid)
			ttmp[:name] = talk.name
			ttmp[:sex] = User.where(:userid => talk.userid).first.sex
			ttmp[:msg] = talk.gMessage
			ttmp[:type] = talk.gType
			ttmp[:tid] = talk._id
			half_type = (talk.created_at.strftime("%P") == "am") ? "오전" : "오후"
			ttmp[:created] = talk.created_at.strftime("%m-%d #{half_type} %l:%M")

			@talks[0] << ttmp
		end
		@members = []
		@members[0] = []
 		@groups << @members
		@groups << @talks

		render :json => @groups
  end

end