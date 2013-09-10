class LogMeetview
  include Mongoid::Document
  include Mongoid::Timestamps
  field :ip, type: String
  field :userid, type: String
  field :mcode, type: String
  field :referer, type: String
  
  # 1. 로그생성 - DB입력
  def self.savelog(ip,userid,mcode,referer)
=begin
	create! do |meetview|		
	  	meetview.ip = ip
	  	meetview.userid = userid
	  	meetview.mcode = mcode
		meetview.referer = referer
	end
=end
  end
end
