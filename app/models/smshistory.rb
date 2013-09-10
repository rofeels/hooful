#encoding: utf-8
class Smshistory
	require 'uri'
	require "net/http"
  include Mongoid::Document
  include Mongoid::Timestamps
	field :sent_id, type: String
	field :senddate, type: String
	field :phone, type: String
	field :callback, type: String
	field :msg, type: String
	field :sent_at, type: String
	field :etc1, type: String
	field :type, type: String
	field :userid, type: String
	field :mCode, type: String
#{"id":"100","senddate":"now","phone":"07082320653",
#"callback":"01020527847","msg":"[Hooful"] :: smstest. \ud6c4\ud480 \ubb38\uc790 \ubc1c\uc1a1\ud14c\uc2a4\ud2b8!!"
#"created_at":"2013-01-11T07:18:43Z","etc1":"now"}

	SmsText = Hash.new
	SmsText[:opener] = "[hooful]"
	SmsText[:reserv] = "{subject}님이 {ticket}의 예약을 신청했어요.예약 가능여부를 선택해주세요!"#XX월 XX일
	#SmsText[:reserv] = "{subject}님이 {ticket}의 {date}자 예약을 신청했어요. 예약 가능여부를 선택해주세요!"#XX월 XX일
	SmsText[:reserv_complete_ingroup] = "{ticket}의 예약이 확정되었어요. 불참할 경우 티켓이 사용처리 됩니다!"
	#SmsText[:reserv_complete_ingroup] = "{ticket}의 {date}자 예약이 확정되었어요. 만약 예약된 날짜에 무단으로  참석하지 않으면 티켓이 사용처리 된답니다!"
	SmsText[:reserv_complete] = "{ticket}의 예약이 확정되었어요.즐거운 활동을 위해 그룹톡에 참여하세요"
	#SmsText[:reserv_complete] = "{ticket}의 {date}자 예약이 확정되었어요. 보다 즐거운 활동을 위해서 후풀의 함께가기에서 그룹톡에 참여하세요!"
	SmsText[:reserv_cancel] = "{ticket}의 예약이 예약불가 되었어요. 다른 날짜로 다시 신청해주세요."
	#SmsText[:reserv_cancel] = "{ticket}의 {date}자 예약이 예약불가 되었어요. 다른 날짜로 다시 신청해주세요."
	SmsText[:pay_success] = "{ticket}의 구매가 완료되었습니다. 참여할 날짜에 예약을 신청해주세요."
	#SmsText[:pay_success] = "{ticket}의 구매가 완료되었습니다. 예약하기에서 참여하고자 하는 날짜에 예약을 신청해주세요."
	def self.create_sample(type,msg)
		create! do |his|
			his.msg = msg
			his.type = type
		end
	end

	# 1. sms 송신 기록 db 저장 시작
	def self.create_history(params) # json으로 들어옴
		create! do |his|
			his.sent_id = params["id"]# if params["id"]
			his.senddate = params["senddate"]# if params["senddate"]
			his.phone = params["phone"]# if params["phone"]
			his.callback = params["callback"]# if params["callback"]
			his.msg = params["msg"]# if params["msg"]
			his.sent_at = params["created_at"]# if params["sent_at"]
			his.etc1 = params["etc1"]# if params["etc1"]
			his.type = params["type"]# if params["type"]
			his.userid = params["userid"]# if params["userid"]
			his.mCode = params["mCode"]# if params["mCode"]
		end
	end
	# 1. sms 송신 기록 db 저장 종료

	# 2. 모임 관련 문자 발송 시작
	SMSBYTE = 80
	def self.send(type, params)
		case type
			when "reserv"
				#params[:userid, host, date, ticket, date, mCode
				@user = User.info(params[:userid])
				@host = User.info(params[:host])
				if @host.phone
					message = SmsText[:opener] + SmsText[:reserv]
					username = @user.name
					if username.length > 3
						username = username.at(0..3)
						username = "#{username}.."
					end
					ticketname = params[:ticket]
					if ticketname.length > 4
						ticketname = ticketname.at(0..4)
						ticketname = "#{ticketname}.."
					end
					message = message.gsub(/\{subject}+/,username)
					message = message.gsub(/\{ticket}+/,ticketname)
					#message = message.gsub(/\{date}+/, params[:date].at(0..9))

					smsdata = Hash.new
					smsdata[:userid] = @host.userid
					smsdata[:msg] = message
					smsdata[:phone] = @host.phone.to_s
					smsdata[:type] = "reserv"
					smsdata[:mCode] = params[:mCode]
					Home.smssend(smsdata)
				end
			when "reserv_complete_ingroup"
				#params[:userid, date, ticket, mCode
				@user = User.info(params[:userid])
				if @user.phone
					message = SmsText[:opener] + SmsText[:reserv_complete_ingroup]
					
					ticketname = params[:ticket]
					if ticketname.length > 4
						ticketname = ticketname.at(0..4)
						ticketname = "#{ticketname}.."
					end
					message = message.gsub(/\{ticket}+/,ticketname)
					#message = message.gsub(/\{date}+/, params[:date])

					smsdata = Hash.new
					smsdata[:userid] = @user.userid
					smsdata[:msg] = message
					smsdata[:phone] = @user.phone.to_s
					smsdata[:type] = "reserv_complete_ingroup"
					smsdata[:mCode] = params[:mCode]
					Home.smssend(smsdata)
				end
			when "reserv_complete"
				#params[:userid, date, ticket, mCode
				@user = User.info(params[:userid])
				if @user.phone
					message = SmsText[:opener] + SmsText[:reserv_complete]
					ticketname = params[:ticket]
					if ticketname.length > 4
						ticketname = ticketname.at(0..4)
						ticketname = "#{ticketname}.."
					end
					message = message.gsub(/\{ticket}+/,ticketname)
					#message = message.gsub(/\{date}+/, params[:date])

					smsdata = Hash.new
					smsdata[:userid] = @user.userid
					smsdata[:msg] = message
					smsdata[:phone] = @user.phone.to_s
					smsdata[:type] = "reserv_complete"
					smsdata[:mCode] = params[:mCode]
					Home.smssend(smsdata)
				end
			when "reserv_cancel"
				#params[:userid, date, ticket, mCode
				@user = User.info(params[:userid])
				if @user.phone
					message = SmsText[:opener] + SmsText[:reserv_cancel]
					ticketname = params[:ticket]
					if ticketname.length > 4
						ticketname = ticketname.at(0..4)
						ticketname = "#{ticketname}.."
					end
					message = message.gsub(/\{ticket}+/,ticketname)
					#message = message.gsub(/\{date}+/, params[:date])

					smsdata = Hash.new
					smsdata[:userid] = @user.userid
					smsdata[:msg] = message
					smsdata[:phone] = @user.phone.to_s
					smsdata[:type] = "reserv_cancel"
					smsdata[:mCode] = params[:mCode]
					Home.smssend(smsdata)
				end
			when "pay_success"
				#params[:userid, ticket, mCode
				@user = User.info(params[:userid])
				if @user.phone
					message = SmsText[:opener] + SmsText[:pay_success]
					ticketname = params[:ticket]
					if ticketname.length > 4
						ticketname = ticketname.at(0..4)
						ticketname = "#{ticketname}.."
					end
					message = message.gsub(/\{ticket}+/,ticketname)

					smsdata = Hash.new
					smsdata[:userid] = @user.userid
					smsdata[:msg] = message
					smsdata[:phone] = @user.phone.to_s
					smsdata[:type] = "pay_success"
					smsdata[:mCode] = params[:mCode]
					Home.smssend(smsdata)
				end
		end
	end

# 2. 모임 관련 문자 발송 종료


end
