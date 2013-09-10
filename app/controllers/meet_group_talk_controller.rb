#encoding: UTF-8
class MeetGroupTalkController < ApplicationController
  respond_to :json
  TALK_LIMIT = 10
  
  def index
    if params[:type] =="members"
		@groups = []
		members =TicketSold.where(:mCode => params[:mcode], :tState.ne => 7)
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

			if mtmp[:name].match(/#{params[:keyword]}/) or mtmp[:userid].match(/#{params[:keyword]}/) or params[:keyword].blank?
				@members[0] << mtmp
			end
		end

		if params[:lastTalk]
			talks= MeetGroupTalk.where(:mCode => params[:mcode], :_id.gt =>params[:lastTalk]).desc(:created_at)
		else
			talks= MeetGroupTalk.where(:mCode => params[:mcode]).desc(:created_at)
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
			talks= MeetGroupTalk.where(:mCode => params[:mcode], :_id.lt =>params[:firstTalk]).not_in(:gType => ["enter", "leave"]).desc(:created_at)
		else
			talks= MeetGroupTalk.where(:mCode => params[:mcode]).not_in(:gType => ["enter", "leave"]).desc(:created_at)
		end

		@talks = []
		@talks[0] = []
		if talks.count > TALK_LIMIT
			ttmp = Hash.new
			ttmp["prev"] = talks.count-TALK_LIMIT
			@talks[0]  << ttmp
		end
		talklimit = talks.limit(TALK_LIMIT)		
		MeetGroupTalk.where(:mCode => params[:mcode], :_id.lte => talklimit.first._id, :_id.gte => talklimit.reverse.first._id).each do |talk|
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
		members = TicketSold.where(:mCode => params[:mcode], :tState.ne => 7)
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

			@match[mtmp[:_id]] = mtmp
			@members[0] << mtmp
		end


		talks= MeetGroupTalk.where(:mCode => params[:mcode]).not_in(:gType => ["enter", "leave"]).desc(:created_at)
		@talks = []
		@talks[0] = []

		talklimit = talks.limit(TALK_LIMIT)
		if talklimit.count > 0
			if talks.count > TALK_LIMIT
				ttmp = Hash.new
				ttmp["prev"] = talks.count-TALK_LIMIT
				@talks[0]  << ttmp
			end
			MeetGroupTalk.where(:mCode => params[:mcode], :_id.lte => talklimit.first._id, :_id.gte => talklimit.reverse.first._id).each do |talk|
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


  def create
	if params[:type] == "send"
		@group_member = TicketSold.where(:mCode => params[:mcode], :tState.ne => 7,:mUserid => params[:mUserid]).first
		@userinfo = User.where(:userid => params[:mUserid]).first
		@group_talk = MeetGroupTalk.sendTalk("msg",params[:message], @userinfo,params[:mcode],1)
    end
		@groups = []

		if params[:lastTalk]
			talks= MeetGroupTalk.where(:mCode => params[:mcode], :_id.gt =>params[:lastTalk]).desc(:created_at)
		else
			talks= MeetGroupTalk.where(:mCode => params[:mcode]).desc(:created_at)
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