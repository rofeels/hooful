class Smsauth
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String
  field :userid, type: String
  field :phone, type: String
  field :authcode, type: String
#{"id":"100","senddate":"now","phone":"07082320653",
#"callback":"01020527847","msg":"[Hooful] :: smstest. \ud6c4\ud480 \ubb38\uc790 \ubc1c\uc1a1\ud14c\uc2a4\ud2b8!!"
#"created_at":"2013-01-11T07:18:43Z","etc1":"now"}
	AUTHTIME = 3600 * 5
	def self.create_authcode(userid, phone, type)
		auth = ''
		create! do |sms|
			sms.userid = userid
			sms.phone = phone
			sms.type = type
			6.times do 
				auth << Random.rand(9).to_s
			end
			sms.authcode = auth
		end
		if auth.blank? or auth.empty? or auth.nil?
			"empty"
		else
			auth
		end
	end

	def self.smsauth_check(userid, phone, authcode)
		t = Time.now
		sms = Smsauth.where('$and' => [{"userid" => userid},{"phone" => phone}]).last
		if sms
			if t.to_i < sms.created_at.to_i + 300 and authcode.to_s == sms.authcode.to_s
				true
			else
				false
			end
		else
			false
		end
	end

end