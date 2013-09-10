#encoding: utf-8
class Payhistory
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String						# type: 결제시 buy, 결제 취소시 refund
  # 모임 정보
  field :mCode, type: String					# 모임 코드
  field :mUserid, type: String				# 참여자 아이디
  # 결제 정보
  field :mid, type: String						# member id
  field :tid, type: String						# 거래 고유번호
  field :paymethod, type: String			# 지불 수단
  field :cardtype, type: String				# 카드 타입
  field :cardauthcode, type: String		# 카드 승인 번호
  field :goodname, type: String				# 상품명
  field :unitprice, type: String			# 가격
  field :goodcurrency, type: String		# 화폐단위
  field :currency_org, type: String		# 원거래가격
  field :price_org, type: String			# 원겨래화폐단위
  field :receipttoname, type: String	# 구매자이름
  field :receipttoemail, type: String	# 구매자메일
  field :receipttotel, type: String		# 구매자전화번호
  field :replyMsg, type: String				# 지불결과메세지
  field :resultcode, type: String			# 지불결과코드
  belongs_to  :hoopartice, autosave: true

=begin
mid 맴버아이디
tid 거래고유번호
mb_serial_no 상점주문번호

paymethod 지불수단코드

300100 basic거래, 300101 basic_auth
300102 ISP거래, 300103 visa3d 거래
300104 USD거래, 3007 무통장 및 가상계좌
300801 핸드폰소액결제, 300802 폰빌거래
300803 ars거래, 3004 실시간계좌이체
300105 CUP거래, 300106 알리페이
300108 AA CODE

cardtype 카드타입

301110 국민카드, 301210 외환카드
301310 BC 카드, 301410 신한카드(구 LG)
301510 삼성카드 301810 신한카드
301610 현대카드, 다이너스카드
301710 롯데카드, 아메리칸익스프레스카드
301915 한미카드 HANMI Card
301923 시티카드 CITY Card

cardauthcode 카드승인번호

goodname 상품명
unitprice 가격
goodcurrency 화폐단위

currency_org 원거래가격
price_org 원겨래화폐단위

receipttoname 구매자이름
receipttoemail 구매자메일
receipttotel 구매자전화번호

replyMsg 지불결과메세지
resultcode 지불결과코드
=end

	def self.create_history(params)
		@payhistory = Payhistory.create(
			:type => "buy",
			# 모임 정보
			:mCode => params[:mCode],										# 모임 코드
			:mUserid => params[:mUserid],								# 참여자 아이디
			# 결제 정보
			:mid => params[:mid],												# member id
			:tid => params[:tid],												# 거래 고유번호
			:paymethod => params[:paymethod],						# 지불 수단
			:cardtype => params[:cardtype],							# 카드 타입
			:cardauthcode => params[:cardauthcode],			# 카드 승인 번호
			:goodname => params[:goodname],							# 상품명
			:unitprice => params[:unitprice],						# 가격
			:goodcurrency => params[:goodcurrency],			# 화폐단위
			:currency_org => params[:currency_org],			# 원거래가격
			:price_org => params[:price_org],						# 원겨래화폐단위
			:receipttoname => params[:receipttoname],		# 구매자이름
			:receipttoemail => params[:receipttoemail],	# 구매자메일
			:receipttotel => params[:receipttotel],			# 구매자전화번호
			:replyMsg => params[:replyMsg],							# 지불결과메세지
			:resultcode => params[:resultcode]
		)
	end

	def self.create_refund_history(params)
		create! do |his|
			his.type = "refund"
			# 모임 정보
			his.mCode = params["mCode"]										# 모임 코드
			his.mUserid = params["mUserid"]								# 참여자 아이디
			# 환불 정보
			his.tid = params["transactionid"]							# = transactionid
			his.replyMsg = params["ReplyMsg"]							# = ReplyMsg
			his.resultcode = params["ReplyCode"]						# = ReplyCode
		end
	end

  def self.loadPay(tid)
    Payhistory.where(:tid => tid).last
  end

end
