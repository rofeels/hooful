#encoding: utf-8
class Home
  include Mongoid::Document

  SECRET = Digest::SHA1.hexdigest("hooful")

# 2. 메일발송 암호화 
  def self.getEncapedCode(type,userid,time)
  	case type
  		when "pwdchange"
  			right_now = DateTime.now.year.to_s
  			right_now << DateTime.now.month.to_s
  			right_now << DateTime.now.day.to_s
  			right_now << DateTime.now.hour.to_s
  			right_now << DateTime.now.min.to_s
  		when "varification"
  			right_now = time.to_s
  	end
  	
  	encaped = type + " " + Base64.encode64( right_now ) + " " + userid
  	encaped = Base64.encode64(encaped)
  	return encaped
  end
# 3. 메일발송 암호 유효성 검사
  def self.checkEncapeCode(encap_userid,type)
    encaped = Hash.new
    right_now = DateTime.now.year.to_s
    right_now << DateTime.now.month.to_s
    right_now << DateTime.now.day.to_s
    right_now << DateTime.now.hour.to_s
    right_now << DateTime.now.min.to_s
    encap_userid = Base64.decode64(encap_userid)
    
    @encap_data = encap_userid.split(' ')
    if @encap_data.length != 3
      encaped[:valid] = false
      encaped[:notice] = "잘못된 접근입니다."
      encaped[:redirect] = {:controller=>'home', :action=>'dindex'}
      return encaped
    end
    encaped[:userid] = @encap_data[2]
    
    case type
      when "pwdchange"
        left_now = Base64.decode64(@encap_data[1])
        left_now = left_now.to_i
        end_time = right_now.to_i
      
        if ((left_now / 100).to_i)%100 == 23
          end_time = end_time.to_i + 100000 - 2300
        else
          end_time << 100
        end
        if right_now.to_i < end_time.to_i
          encaped[:valid] = true
          encaped[:redirect] = {:controller=>'users', :action=>'change_password'}
          encaped
        else
          encaped[:valid] = false
          encaped[:notice] = "인증시간이 지났습니다.<br/>인증메일을 받으실 E-mail주소를 입력해주시기 바랍니다."
          encaped[:redirect] = {:controller=>'users', :action=>'reset_password'}
        end
      when "varification"
        #user = User.find_by_userid(encaped[:userid])
				user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => encaped[:userid]}]).last
        encap_org = type + " " + Base64.encode64( user.created_at.to_s ) + " " + user.userid
      
        if user.email_auth == 1
          encaped[:valid] = false
          encaped[:notice] = "#{user.name}님, 이미 인증되었습니다."
          encaped[:redirect] = {:controller=>'home', :action=>'dindex'}
          encaped[:userid] = user.userid
        elsif encap_userid == encap_org
          encaped[:valid] = true
          encaped[:notice] = "#{user.name}님, 인증되었습니다."
          user.email_auth = 1
					user.acct_auth = 2
          encaped[:userid] = user.userid
          user.save
          encaped[:redirect] = {:controller=>'home', :action=>'dindex'}
        else
          encaped[:valid] = false
          encaped[:notice] = "#{user.name}님, 인증코드가 다릅니다."
          encaped[:redirect] = "https://hooful.com/#{encap_org}"
        end
      end
    return encaped
  end
  def self.awsFileCheck(filename, location, type)
		@@BUCKET = "hoofulimg"
    AWS::S3::DEFAULT_HOST.replace "s3-ap-northeast-1.amazonaws.com" 
    AWS::S3::Base.establish_connection!(
      :access_key_id     => 'AKIAIKNA32CMDL6KU2RA',
      :secret_access_key => 'HlKnKA9/etPNVOsAxFww/57YgGDDm9nYCURGjXnu'
    )
    picpath = @@BUCKET.to_s + "/" + location# + "/" + type
	if (not type.nil?) or (not type.blank?) or (not type.empty?)
		picpath += "/" + type
	end
=begin    if AWS::S3::S3Object.exists? filename, picpath
      true
		else
			false
    end
=end
  end
  def self.smssend(params)
		data = Hash.new
		data[:senddate] = (params[:senddate]) ? params[:senddate] : "now"		#발송시간 now로 하면 즉시전송, 20131230120000 예약전송
		data[:phone] = params[:phone]		#받는번호
		data[:callback] = "15995892"	#보내는번호
		data[:msg] = params[:msg]
		data[:logid] = "openapi"
		data[:auth_key] = "201301sms"
		data[:userid] = params[:userid]
		data[:type] = params[:type]
		data[:mCode] = params[:mCode]

		#uri = URI('http://hoofula.hooful.com/hardworker/sms.json')
		#res = Net::HTTP.post_form(uri, data)
		#data[:res] = res.inspect
		#Smshistory.create(data)
  end

  def self.encode(text)
    Base64.encode64("#{text}#hUser")
  end

  def self.decode(text)
   a=Base64.decode64(text)
   b=a.strip.split("#")
   b[0]
  end

  def self.mpSend(params)
    data = Hash.new
    data[:apikey] = "2d28a049e7697de9319f9b5d0cdecc5ce246212c"
		data[:daumaction] = params[:daumaction]
		data[:buddyId] = params[:buddyId]
		data[:content] = params[:content]

    url = URI.parse("https://apis.daum.net/mypeople/buddy/send.json")
    req = Net::HTTP::Post.new(url.path, {'Content-Type' =>'application/x-www-form-urlencoded'})
    req.set_form_data({'buddyId'=>params[:buddyId], 'content'=>params[:content], 'apikey'=>data[:apikey]})
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    response = res.start {|http| http.request(req) }
    Mplog.create_log(params[:daumaction], data, response.body)
    response.body
  end

  def self.mpSendGroup(params)
    data = Hash.new
    data[:apikey] = "2d28a049e7697de9319f9b5d0cdecc5ce246212c"
		data[:daumaction] = params[:daumaction]
		data[:buddyId] = params[:buddyId]
		data[:groupId] = params[:groupId]
		data[:content] = params[:content]

    url = URI.parse("https://apis.daum.net/mypeople/group/send.json")
    req = Net::HTTP::Post.new(url.path, {'Content-Type' =>'application/x-www-form-urlencoded'})
    req.set_form_data({'groupId'=>params[:groupId], 'content'=>params[:content], 'apikey'=>data[:apikey]})
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    response = res.start {|http| http.request(req) }
    Mplog.create_log(params[:daumaction], data, response.body)
    response.body
  end
end
