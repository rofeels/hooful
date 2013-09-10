#encoding: utf-8
require 'net/http'

class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  field :userid, type: String
  field :type, type: String
  field :subject, type: String
  field :spicture, type: String
  field :sname, type: String
  field :mcode, type: String
  field :message, type: String
  field :check, type: Integer
  field :checked_at, type: Time
  field :enable, type: Integer
  index({ userid: 1 }, { unique: false})
 
  NotificationAdmin = Hash.new
  NotificationAdmin[:hooful] = "hooful@hooful.com"
  NotificationAdmin[:eb] = "eb.ddew@gmail.com"
  NotificationAdmin[:bg] = "bg8710@naver.com"

=begin
  알림 치환문자
  {subject} 알림 발생자
  {object} 알림 대상자
  {n} bind 개수
  {grouptalk} 그룹톡 이름
  {preview} 후기댓글/방명록댓글/방명록내용 preview
  {date} 예약 날짜 ex) XX월 XX일자
=end

  NotificationText = Hash.new
  NotificationText[:group_new_mbr] = "{grouptalk} 그룹톡에 {subject}님이 참여했어요!"
  NotificationText[:group_new_msg] = "{grouptalk} 그룹톡에 {subject}님이 새로운 톡을 남겼어요!"
  NotificationText[:group_new_buy] = "{grouptalk} 그룹톡에 {subject}님이 {ticket} 티켓을 구매했어요!"
  NotificationText[:group_edit_date] = "{grouptalk} 그룹톡의 출발날짜가 변경되었어요. 확인해보세요!"
  NotificationText[:group_confirm_date] = "{grouptalk} 그룹톡의 출발날짜가 확정되었어요. 확인해보세요!"
  NotificationText[:group_edit_title] = "{grouptalk} 그룹톡의 제목이 변경되었어요. 확인해보세요!"
  NotificationText[:group_d3_paid] = "{grouptalk} 그룹톡의 출발 3일 전 입니다. 아직 {subject}님이 티켓을 구매하지 않았어요!"
  NotificationText[:group_d3_notpaid] = "{grouptalk} 그룹톡의 출발 3일 전 입니다. 후풀은 출발 3일전까지 티켓구매와 예약 완료가 원칙이랍니다. 서두르세요!"
  NotificationText[:group_d1_paid] = "{grouptalk} 그룹톡의 출발 하루 전 입니다. 두근두근!"
  NotificationText[:group_d1_notpaid] = "{grouptalk} 그룹톡의 출발 하루 전이에요. 출발일에 임박해서 예약신청을 할 경우 업체사정에 따라 예매가 불가능 할 수도 있어요!"
  NotificationText[:review_cmt] = "{subject}님이 회원님의 후기에 댓글을 남겼어요! {preview}"
  NotificationText[:review_cmt_bind] = "{subject}님 외 {n}명이 회원님의 후기에 댓글을 남겼어요!"
  NotificationText[:guestbook_write] = "{subject}님이 새로운 방명록을 남겼어요! {preview}"
  NotificationText[:guestbook_cmt] = "{subject}님이 {object}님이 작성한 방명록에 댓글을 남겼어요! {preview}"
  NotificationText[:guestbook_rply] = "{subject}님이 {object}님의 방명록 게시글에 댓글을 남겼어요! {preview}"
  NotificationText[:reserved_request] = "{subject}님이 {ticket}의 {date} 예약을 신청했어요. 예약 가능여부를 선택해주세요!"
  NotificationText[:reserved_complete_group] = "{ticket}의 {date} 예약이 확정되었어요. 만약 예약된 날짜에 무단으로  참석하지 않으면 티켓이 사용처리 된답니다!"
  NotificationText[:reserved_complete_nogroup] = "{ticket}의 {date} 예약이 확정되었어요. 보다 즐거운 활동을 위해서 후풀의 함께가기에서 그룹톡에 참여하세요!"	# 함께가기 클릭 시 커뮤니티에 그룹톡 부분으로 포커스 상태로 이동
  NotificationText[:reserved_unable] = "{ticket}의 {date} 예약이 예약불가 되었어요. 다른 날짜로 다시 신청해주세요."
=begin
  NotificationText[:ticket_buy] = "{ticket}의 구매가 완료되었습니다. 예약하기에서 참여하고자 하는 날짜에 예약을 신청해주세요. 보다 즐거운 활동을 위해서 후풀의 함께가기에서 그룹톡에 참여하세요!"	# 함께가기 클릭 시 커뮤니티에 그룹톡 부분으로 포커스 상태로 이동
=end
  NotificationText[:ticket_buy] = "{ticket}의 구매가 완료되었습니다."
  NotificationText[:ticket_expire_7d] = "{ticket}티켓의 유효기간이 일주일 남았어요. 유효기간이 지나면 티켓이 사용처리 된답니다. 서두르세요!"
  NotificationText[:customer_inquiry] = "문의사항에 답변이 완료되었어요. 항상 노력하는 hooful이 될게요. 감사합니다!"
  NotificationText[:qna_inquiry] = "{subject}이 회원님의 Q&A에 댓글을 남겼어요."
  NotificationText[:hooful] = ""

  def self.LoginCheck(userid)
    d7ago_s = Time.now + 7.days
	d7ago_s = d7ago_s.strftime("%Y-%m-%d").to_s
	d7ago_s = Date.strptime(d7ago_s, "%Y-%m-%d")
    d7ago_e = Time.now + 8.days
	d7ago_e = d7ago_e.strftime("%Y-%m-%d").to_s
	d7ago_e = Date.strptime(d7ago_e, "%Y-%m-%d")

    d3ago = Time.now + 3.days
	d3ago = d3ago.strftime("%Y-%m-%d, ").to_s
	d1ago = Time.now + 1.days
	d1ago = d1ago.strftime("%Y-%m-%d, ").to_s

	groupall = GroupMember.where(:mUserid => userid)
	Group.where(:_id.in => groupall.map(&:group_id),:gDate => d3ago).each do |group|
		userticket =0
		userticket= TicketSold.where(:mCode => group.mCode, :mUserid => userid, :tState.ne => 7).count if group.mCode
		if userticket> 0
			Notification.send("group_d3_paid", userid, group.id, "")
		else
			Notification.send("group_d3_notpaid", userid, group.id, "")
		end
	end

	Group.where(:_id.in => groupall.map(&:group_id),:gDate => d1ago).each do |group|
		userticket =0
		userticket= TicketSold.where(:mCode => group.mCode, :mUserid => userid, :tState.ne => 7).count if group.mCode
		if userticket> 0
			Notification.send("group_d1_paid", userid, group.id, "")
		else
			Notification.send("group_d1_notpaid", userid, group.id, "")
		end
	end

	ticketall = TicketSold.where(:mUserid => userid, :tState.ne => 7)
	Meet.where(:mCode.in => ticketall.map(&:mCode),:mDateE.gte => d7ago_s,:mDateE.lt => d7ago_e).each do |meet|
		Notification.send("ticket_expire_7d", userid, meet.mCode,"")
	end



  end
  # 1. Notification전송
  def self.send(type, subject, mcode,etc)
	  
	case type
		when "group_new_mbr" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_new_mbr]
			message = message.gsub(/\{subject}+/, "<a href='/user/#{Home.encode(@subject.userid)}'>#{@subject.name}</a>")
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
			GroupMember.where(:group_id => mcode).each do |member|
				if member.mUserid != @subject.userid
					Notification.save(member.mUserid, "group_new_mbr", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(member.mUserid)#socket push
				end
			end
		when "group_new_msg" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_new_msg]
			message = message.gsub(/\{subject}+/, "<a href='/user/#{Home.encode(@subject.userid)}'>#{@subject.name}</a>")
			#message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
      message = message.gsub(/\{grouptalk}+/, "#{@group.gTitle}")
			GroupMember.where(:group_id => mcode).each do |member|
				if member.mUserid != @subject.userid
					Notification.save(member.mUserid, "group_new_msg", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(member.mUserid)#socket push
				end
			end
		when "group_new_buy" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_new_buy]
			message = message.gsub(/\{subject}+/, "<a href='/user/#{Home.encode(@subject.userid)}'>#{@subject.name}</a>")
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
			message = message.gsub(/\{ticket}+/, "<a href='/g/#{@group.mCode}'>#{etc}<	/a>")
			GroupMember.where(:group_id => mcode).each do |member|
				if member.mUserid != @subject.userid
					Notification.save(member.mUserid, "group_new_buy", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(member.mUserid)#socket push
				end
			end
		when "group_edit_date" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_edit_date]
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
			GroupMember.where(:group_id => mcode).each do |member|
				if member.mUserid != @subject.userid
					Notification.save(member.mUserid, "group_edit_date", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(member.mUserid)#socket push
				end
			end

		when "group_confirm_date" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_confirm_date]
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
			GroupMember.where(:group_id => mcode).each do |member|
				if member.mUserid != @subject.userid
					Notification.save(member.mUserid, "group_confirm_date", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(member.mUserid)#socket push
				end
			end

		when "group_edit_title" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_edit_title]
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
			GroupMember.where(:group_id => mcode).each do |member|
				if member.mUserid != @subject.userid
					Notification.save(member.mUserid, "group_edit_title", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(member.mUserid)#socket push
				end
			end

		when "group_d3_paid" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			members = ""

			GroupMember.where(:group_id =>@group._id).each do |member|
				userticket =0
				userticket= TicketSold.where(:mCode => @group.mCode, :mUserid => member.mUserid, :tState.ne => 7).count if @group.mCode
				if userticket == 0
					uinfo = User.info(member.mUserid)
					members = "#{members}<a href='/user/#{uinfo.link}'>#{uinfo.name}</a>, "
				end
			end


			if !members.blank?
				message = NotificationText[:group_d3_paid]
				message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")
				message = message.gsub(/\{subject}+/,members.at(0..-3))
				
				noticheck = Notification.where(:userid => @subject.userid , :type => "group_d3_paid", :message => message).exists?
				if noticheck == false
					Notification.save(@subject.userid, "group_d3_paid", @subject.userid, @subject.picture, @subject.name, "", message)
					Notification.push(@subject.userid)#socket push
				end
			end

		when "group_d3_notpaid" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_d3_notpaid]
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")

			noticheck = Notification.where(:userid => @subject.userid , :type => "group_d3_notpaid", :message => message).exists?
			if noticheck == false
				Notification.save(@subject.userid, "group_d3_notpaid", @subject.userid, @subject.picture, @subject.name, "", message)
				Notification.push(@subject.userid)#socket push
			end

		when "group_d1_paid" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_d1_paid]
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")

			noticheck = Notification.where(:userid => @subject.userid , :type => "group_d1_paid", :message => message).exists?
			if noticheck == false
				Notification.save(@subject.userid, "group_d1_paid", @subject.userid, @subject.picture, @subject.name, "", message)
				Notification.push(@subject.userid)#socket push
			end
		when "group_d1_notpaid" then
			@subject = User.info(subject)
			@group = Group.find(mcode)
			message = NotificationText[:group_d1_notpaid]
			message = message.gsub(/\{grouptalk}+/, "<a href='/g/#{@group._id}'>#{@group.gTitle}</a>")

			noticheck = Notification.where(:userid => @subject.userid , :type => "group_d1_notpaid", :message => message).exists?
			if noticheck == false
				Notification.save(@subject.userid, "group_d1_notpaid", @subject.userid, @subject.picture, @subject.name, "", message)
				Notification.push(@subject.userid)#socket push
			end

		when "review_cmt" then
			@subject = User.info(subject)
			@review = Review.where(:rCode =>mcode).first
			message = NotificationText[:review_cmt]
			message = message.gsub(/\{subject}+/, "<a href='/user/#{Home.encode(@subject.userid)}'>#{@subject.name}</a>")
			preview = etc
			preview = "#{preview.slice(0, 15)}..." if preview.length > 15
			message = message.gsub(/\{preview}+/,  "<a href='/r/#{mcode}'>#{preview}</a>")

			Notification.save(@review.mWriter, "review_cmt", @subject.userid, @subject.picture, @subject.name, "", message)
			Notification.push(@review.mWriter)#socket push

		when "guestbook_write" then
			@subject = User.info(subject)
	
			message = NotificationText[:guestbook_write]
			message = message.gsub(/\{subject}+/, "<a href='/user/#{Home.encode(@subject.userid)}'>#{@subject.name}</a>")
			preview = etc
			preview = "#{preview.slice(0, 15)}..." if preview.length > 15
			message = message.gsub(/\{preview}+/,  "<a href='/user/#{Home.encode(mcode)}'>#{preview}</a>")

			Notification.save(mcode, "guestbook_write", @subject.userid, @subject.picture, @subject.name, "", message)
			Notification.push(mcode)#socket push

		when "guestbook_cmt" then
			#아직 기능구현 안되어있음
		when "guestbook_rply" then
			#아직 기능구현 안되어있음
		when "reserved_request" then
			@subject = User.info(subject)
			addtion = etc.split("/,/")
			message = NotificationText[:reserved_request]
			message = message.gsub(/\{subject}+/, "<a href='/user/#{Home.encode(@subject.userid)}'>#{@subject.name}</a>")
			message = message.gsub(/\{ticket}+/,"<a href='/#{addtion[0]}'>#{addtion[1]}</a>")
			message = message.gsub(/\{date}+/, addtion[2].at(0..-3))
			Notification.save(mcode, "reserved_request", @subject.userid, @subject.picture, @subject.name, "", message)
			Notification.push(mcode)#socket push

		when "reserved_complete_group" then
			@subject = User.info(subject)
			addtion = etc.split("/,/")
			meet = Meet.where(:mCode => mcode).first
			@host = User.info(meet.mHost)
			message = NotificationText[:reserved_complete_group]
			message = message.gsub(/\{ticket}+/,"<a href='/#{mcode}'>#{addtion[0]}</a>")
			message = message.gsub(/\{date}+/, addtion[1].at(0..-3))
			Notification.save(@subject.userid, "reserved_complete_group", @host.userid, @host.picture, @host.name, "", message)
			Notification.push(@subject.userid)#socket push

		when "reserved_complete_nogroup" then
			@subject = User.info(subject)
			addtion = etc.split("/,/")
			meet = Meet.where(:mCode => mcode).first
			@host = User.info(meet.mHost)
			message = NotificationText[:reserved_complete_nogroup]
			message = message.gsub(/\{ticket}+/,"<a href='/#{mcode}'>#{addtion[0]}</a>")
			message = message.gsub(/\{date}+/, addtion[1].at(0..-3))
			Notification.save(@subject.userid, "reserved_complete_nogroup", @host.userid, @host.picture, @host.name, "", message)
			Notification.push(@subject.userid)#socket push

		when "reserved_unable" then
			@subject = User.info(subject)
			addtion = etc.split("/,/")
			meet = Meet.where(:mCode => mcode).first
			@host = User.info(meet.mHost)
			message = NotificationText[:reserved_unable]
			message = message.gsub(/\{ticket}+/,"<a href='/#{mcode}'>#{addtion[0]}</a>")
			message = message.gsub(/\{date}+/, addtion[1].at(0..-3))
			Notification.save(@subject.userid, "reserved_unable", @host.userid, @host.picture, @host.name, "", message)
			Notification.push(@subject.userid)#socket push

		when "ticket_buy" then
			@subject = User.info(subject)
			meet = Meet.where(:mCode => mcode).first
			@host = User.info(meet.mHost)
			message = NotificationText[:ticket_buy]
			message = message.gsub(/\{ticket}+/,"<a href='/#{mcode}'>#{etc}</a>")
			Notification.save(@subject.userid, "ticket_buy", @host.userid, @host.picture, @host.name, "", message)
			Notification.push(@subject.userid)#socket push

		when "ticket_expire_7d" then
			@subject = User.info(subject)
			@meet = Meet.where(:mCode => mcode).first
			message = NotificationText[:ticket_expire_7d]
			message = message.gsub(/\{ticket}+/, "<a href='/#{@meet.mCode}'>#{@meet.mTitle}</a>")

			Notification.save(@subject.userid, "ticket_expire_7d", @subject.userid, @subject.picture, @subject.name, "", message)
			Notification.push(@subject.userid)#socket push

		when "customer_inquiry" then
			@subject = User.info("hooful@hooful.com")
			message = NotificationText[:customer_inquiry]
			Notification.save(subject, "customer_inquiry", @subject.userid, @subject.picture, @subject.name, "", message)
			Notification.push(subject)#socket push

		when "qna_inquiry" then
			#아직 기능구현 안되어있음

		when "hooful" then
			#아직 기능구현 안되어있음

		else
		end			

  end

  # 2. Notification생성 - DB입력
  def self.save(userid, type, subject, spicture, sname, mcode, message)
	create! do |notification|		
	  	notification.userid = userid
	  	notification.type = type
		notification.subject = subject
		notification.spicture = spicture
		notification.sname = sname
		notification.mcode = mcode
		notification.message = message
		notification.check = 0
		notification.enable = 1
	end
  end
  # 3. Notification출력
  def self.load(userid)
	  map = %Q{
		function() {
		  if(this.userid == "#{userid}"){
			  if(this.type == "group_new_mbr" ||this.type == "group_new_msg" ||this.type == "group_new_buy" ||this.type == "group_d3_paid" ||this.type == "review_cmt" ||this.type == "guestbook_write" ||this.type == "guestbook_cmt" ||this.type == "guestbook_rply" ||this.type == "reserved_request"){
				  emit({type: this.type, mcode: this.mcode} , {id: this._id, check: this.check, message: this.message, subject: this.subject, spicture: this.spicture, sname: this.sname, count: 1, created_at: this.created_at});
			  }else{
				  emit({type: this.type, mcode: this.mcode, created_at: this.created_at} , {id: this._id, check: this.check, message: this.message, subject: this.subject, spicture: this.spicture, sname: this.sname, count: 1, created_at: this.created_at});
			  }
		  }
		}
	  }

	  reduce = %Q{
		function(key, values) {
		 var result = {id: "", check: 1, message: "", subject: "", spicture: "", sname: "", count: 0, created_at: ""};
		  values.forEach(function(value) {
			if(value.check == 0){
				result.id += "," + value.id;
				result.check = value.check;
			}
			result.subject = value.subject;
			result.spicture = value.spicture;
			result.sname = value.sname;
			result.message = value.message;
			result.count += value.count;
			result.created_at = value.created_at;
		  });	
		  return result;
		}
	  }
	@notification = Hash.new
	unchecked = 0
	Notification.collection.map_reduce(map, reduce, {:out => {:inline => 1}, :raw => true})["results"].each_with_index do |noti, i|
		if noti["value"]["count"].to_i > 1
			if noti["_id"]["type"] == "group_new_msg"
				noti["value"]["message"].gsub!(/<a href=\'\/user\/.+?<\/a>님이 새로운 톡을 남겼어요!/m, "#{(noti['value']['count']).to_i}개의 톡이 있어요!")
			else
				noti["value"]["message"].gsub!(/\<\/a\>님이 /, "\<\/a\>님 외 #{(noti['value']['count']-1).to_i}명이 ")
			end
		end
		unchecked +=1 if noti["value"]["check"].to_i == 0
		@notification[noti["value"]["created_at"]] = {
			:type => noti["_id"]["type"],
			:mcode => noti["_id"]["mcode"],
			:id => noti["value"]["id"],
			:check => noti["value"]["check"],
			:subject => noti["value"]["subject"],
			:spicture => noti["value"]["spicture"],
			:sname => noti["value"]["sname"],
			:message => noti["value"]["message"],
			:count => noti["value"]["count"]
		}
	end
	@notification = @notification.sort.reverse# = Notification.where(userid: userid).desc(:_id)
	@notification[@notification.length] = [unchecked]
	@notification
  end
  # 4. Notification 확인
  def self.check(userid, nid)
	@checkid = nid.split(',')
	@checkid.each do |checkid|
		if !checkid.blank?
			Notification.where(_id: checkid).update_all({"check" => 1})
		end
	end
	@notification = Notification.where(userid: userid, check: 0).count
  end
  def self.push(userid)
	  url = "http://hooful.com:6530/push/notification/#{userid}"
      res = Net::HTTP.post_form(URI.parse(URI.encode(url)),{})


      # 200 implies successfully sent.
      # There is nothing we can do if the targe user is not online(404)
      # For any other error, raise Exception
      unless ["200", "404"].include? res.code
        #raise Exception.new("Error: #{res.code}")
      end
  end
end
