#encoding: utf-8
class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Spacial::Document
  field :name, type: String
  field :provider, type: String
  field :uid, type: String
  field :userid, type: String
  field :password, type: String
  field :password_confirmation, type: String
  field :userpic, type: String
  field :fuid, type: String
  field :tuid, type: String
  field :noti, type: String
  field :coverpic, type: String
  field :dob, type: String
  field :local, type: String
  field :job, type: String
  field :phone, type: String
  field :comment, type: String
  field :email_auth, type: Integer
  field :userpicname, type: String
  field :fbauth, type: String
  field :tauth, type: String
  field :tsecret, type: String
  field :sex, type: String
  field :tid, type: String
  field :guid, type: String
  field :gauth, type: String
  field :kakao, type: String
  field :adtoken, type: String
  field :gdtoken, type: String
  field :phone_auth, type: Integer
  field :acct_auth, type: Integer
  field :category, type: String
  CARDNUM = 9
  def valid

  end

  #1. 회원 유효검사(로그인, 비밀번호찾기, 비밀번호수정)
  def self.find_valid_user(userid,password,action)
		case action
			when "twitter"
				@user = Member.find_by_tid(userid)
			when "facebook"
				@user = Member.find_by_fuid(userid)
			else
				@user = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => userid}]).last
		end

		case action
			when "signin"
			if @user and (@user.password == Digest::SHA2.hexdigest(password))
				@user[:valid] = true
				@user[:notice] = @user.name + "님, 환영합니다~"
				@user[:redirect] = {:controller=>'home', :action=>'index'}
			else
				@user = Hash.new
				@user[:valid] = false
				@user[:notice] = "로그인에 실패하였습니다."
				@user[:redirect] = {:controller=>'user', :action=>'signin'}
			end
			when "twitter"
			if @user
				@user[:picture] = "http://api.twitter.com/1/users/profile_image/"+@user.tuid+"?size=original"
				@user[:valid] = true
				@user[:notice] = @user.name + "님, 환영합니다~"
				@user[:redirect] = {:controller=>'home', :action=>'index'}
			else
				@user = Hash.new
				@user[:valid] = false
				@user[:notice] = "로그인에 실패하였습니다."
				@user[:redirect] = {:controller=>'user', :action=>'signin'}
			end
			when "facebook"
			if @user
				@user[:picture] =  "http://graph.facebook.com/"+@user.fuid+"/picture&type=large"
				@user[:valid] = true
				@user[:notice] = @user.name + "님, 환영합니다~"
				@user[:redirect] = {:controller=>'home', :action=>'index'}
			else
				@user = Hash.new
				@user[:valid] = false
				@user[:notice] = "로그인에 실패하였습니다."
				@user[:redirect] = {:controller=>'user', :action=>'signin'}
			end
			when "reset_password"
			if @user
				@user[:valid] = true	
				@user[:notice] = "인증메일이 발송되었습니다.<br/>가입하신 E-mail 수신함을 확인해 주세요."
				@user[:redirect] = {:controller=>'home', :action=>'index'}
			else
				@user = Hash.new
				@user[:valid] = false	
				@user[:notice] = "존재하지 않는 계정입니다."
				@user[:redirect] = {:controller=>'user', :action=>'reset_password'}
			end
			 when "change_password"
				@user.password = Digest::SHA2.hexdigest(password)
			if @user.save
				@user[:valid] = true	
				@user[:notice] = "암호가 변경되었습니다. 다시 로그인 해주세요."
				@user[:redirect] = {:controller=>'user', :action=>'signin'}
			else
				@user = Hash.new
				@user[:valid] = false	
				@user[:notice] = "존재하지 않는 계정입니다."
				@user[:redirect] = {:controller=>'user', :action=>'reset_password'}
			end
			
		end
		
		return @user
		
  end

  def interest_icon
	@result = ""
	if self.interest
		@interest = ActiveSupport::JSON.decode(self.interest)
		@interest.each do |k, v|
			if v == 1
				interest_id = k.gsub('cat', '')
				interest = Interest.where(_id: interest_id.to_i).first
				@result += "\n<li class='interest'><i class='#{interest.code}'></i><a href='/category/#{interest.code}'></a></li>" if interest
			end
		end
	end
	return @result
  end

  def picture
	if self.userpic
		case self.userpic
			when "twitter"
				"https://api.twitter.com/1/users/profile_image/#{self.tuid}?size=original"
			when "facebook"
				"https://graph.facebook.com/#{self.fuid}/picture?type=large&return_ssl_resources=1"
			when "hooful"
				"#{S3ADDR}userpic/noimage.png"
			else
				"#{S3ADDR}userpic/thumb/#{self.userpic}"
		  end
	else
=begin		if Home.awsFileCheck(self.userpic.to_s, 'userpic', 'thumb')
		  "#{S3ADDR}userpic/thumb/#{self.userpic}"
		elsif Home.awsFileCheck(self.userpic.to_s, 'userpic', '')
		  "#{S3ADDR}userpic/#{@userinfo.userpic}"
		else
		  "#{S3ADDR}userpic/noimage.png"
		end
=end
		"#{S3ADDR}userpic/noimage.png"

	end
  end
  def sex
	  (self.sex == 1 ) ? "남":"여"
  end
  def age
	(Time.now.year.to_i - self.dob.to_s[0..3].to_i) + 1
  end
  def coverpicture
    coverpic = self.coverpic
    coverpic ||= "default/default#{(Random.rand(9)+1)}.jpg"
    "#{S3ADDR}coverpic/#{coverpic}"
  end
  def create_number
	  Meet.where(mHost: self.userid).count	
  end
  def participate_number
	  Hoopartice.where(mUserid: self.userid).count	
  end
  def attendance_rate
    total = Hoopartice.where(mUserid: self.userid).count	
    attendance = Hoopartice.where(mUserid: self.userid, mCheck: '1').count	
    "%.2f" % (attendance.to_f/total*100)
  end
  def snslist
    snslist = ""
    snslist += "<a href=\"https://twitter.com/account/redirect_by_id?id=#{self.tuid}\" class=\"btn-auth\" target=\"_blank\"><i class=\"twitter\"></i>인증</a>" if !self.tauth.nil? and !self.tauth.blank?
    snslist += "<a href=\"http://www.facebook.com/#{self.fuid}\" class=\"btn-auth\" target=\"_blank\"><i class=\"facebook\"></i>인증</a>" if !self.fbauth.nil? and !self.fbauth.blank?
    snslist += "<a href=\"mailto:#{self.userid}\" class=\"btn-auth\"><i class=\"email\"></i>인증</a>" if self.email_auth == 1 or self.email_auth == '1'
  end
  def snslist_share
    snslist = ""
    snslist += "<div class=\"btn-auth\"><i class=\"twitter\"></i></div>" if !self.tauth.nil? and !self.tauth.blank?

    snslist += "<div class=\"btn-auth\"><i class=\"facebook\"></i></div>" if !self.fbauth.nil? and !self.fbauth.blank?
  end
  def snslist_all
    snslist = ""
    snslist += (!self.tauth.nil? and !self.tauth.blank?)? "<a href=\"https://twitter.com/account/redirect_by_id?id=#{self.tuid}\" target=\"_blank\" class=\"btn-auth\"><i class=\"twitter\"></i>연결</a>" : "<span class=\"btn-auth  disabled\"><i class=\"twitter\"></i>인증</span>" 

    snslist += (!self.fbauth.nil? and !self.fbauth.blank?)? "<a href=\"http://www.facebook.com/#{self.fuid}\" target=\"_blank\" class=\"btn-auth\"><i class=\"facebook\"></i>연결</a>" : "<span class=\"btn-auth  disabled\"><i class=\"facebook\"></i>인증</span>" 

    snslist += (self.phone_auth == 1 or self.phone_auth == '1')? "<a href=\"tel:#{self.phone}\" class=\"btn-auth\"><i class=\"phone\"></i>연결</a>" : "<span class=\"btn-auth  disabled\"><i class=\"phone\"></i>인증</span>" 

    snslist += (self.email_auth == 1 or self.email_auth == '1')? "<a href=\"mailto:#{self.userid}\" class=\"btn-auth\"><i class=\"email\"></i></span>연결</a>" : "<span class=\"btn-auth  disabled\"><i class=\"email\"></i>인증</span>" 
  end
  def meet_participated
	  partice = Hoopartice.where(mUserid: self.userid)
	  Meet.where(:mCode.in => partice.map(&:mCode)).limit(CARDNUM).desc(:mDate)
  end
  def meet_hosted
	  Meet.where(:mHost => self.userid).limit(CARDNUM).desc(:mDate)
  end
  def meet_hooed
	  hoo = Hoolike.where(mUserid: self.userid)
	  Meet.where(:mCode.in => hoo.map(&:mCode)).limit(CARDNUM).desc(:mDate)
  end
  

  def self.info(users)
    #@userinfo = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => users}]).last unless users.blank?
	@userinfo = Member.where(:userid => users, :acct_auth.gt => 0).last unless users.blank?
    @userinfo ||= Member.new
  end

  def self.signin(userid, password)
    #@user = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => userid}]).last
    @user = Member.where(:userid => userid, :acct_auth.gt => 0).last
    @user = false unless @user and (@user.password == Digest::SHA2.hexdigest(password))
    case @user.userpic
      when "hooful"
        @user[:picture] = "#{S3ADDR}userpic/noimage.png"
      when "twitter"
        @user[:picture] = "https://api.twitter.com/1/users/profile_image/"+@user.tuid.to_s+"?size=original"
      when "facebook"
        @user[:picture] = "https://graph.facebook.com/"+@user.fuid.to_s+"/picture?type=large&return_ssl_resources=1"
      else
        if Home.awsFileCheck(@user.userpic.to_s, 'userpic', 'thumb')
          @user[:picture] = S3ADDR + "userpic/thumb/#{@userinfo.userpic}"
        elsif Home.awsFileCheck(@user.userpic.to_s, 'userpic', '')
          @user[:picture] = S3ADDR + "userpic/#{@userinfo.userpic}"
        else
          @user[:picture] = S3ADDR + "userpic/noimage.png"
        end
    end
    return @user
  end

  def self.signin_with_provider(provider, uid)
    @check = true
    case provider
      when "twitter"
        @user = Member.find_by_tuid(uid)
        unless @user
          @check = false
        end
      when "facebook"
        @user = Member.find_by_fuid(uid)
        unless @user
          @check = false
        end
      when "hooful"
        @user = Member.find_by_userid(uid)
        unless @user
          @check = false
        end
	  end

    if @check
      @user[:userpic] ||= "hooful"
      case @user[:userpic]
        when "hooful"
          @user[:picture] = "#{S3ADDR}userpic/noimage.png"
        when "twitter"
          @user[:picture] = "https://api.twitter.com/1/users/profile_image/"+@user[:tuid].to_s+"?size=original"
        when "facebook"
          @user[:picture] = "https://graph.facebook.com/"+@user[:fuid].to_s+"/picture?type=large&return_ssl_resources=1"
        else
          if Home.awsFileCheck(@user[:userpic].to_s, 'userpic', 'thumb')
            @user[:picture] = S3ADDR + "userpic/thumb/#{@userinfo.userpic}"
          elsif Home.awsFileCheck(@user[:userpic].to_s, 'userpic', '')
            @user[:picture] = S3ADDR + "userpic/#{@userinfo.userpic}"
          else
            @user[:picture] = S3ADDR + "userpic/noimage.png"
          end
      end
    end
    return @user
  end

  # 3. 회원가입
  def self.userpic_upload(mParam)
    if mParam["uploadFile"]
      filename = Home.fileUpload(mParam["uploadFile"],mParam["sessionid"],'userpic')
    else
      filename = Hash.new
      filename[:vname] = nil
      filename[:name] = nil
    end
    end
      
    def self.create_user(params)
      params[:fuid] ||= nil
      params[:tuid] ||= nil
      params[:uid] ||= nil
          # 3-1. 회원가입 경로
      if params[:provider] == "twitter"
        params[:uid] = params[:tuid]
      elsif params[:provider] == "facebook"
        params[:uid] = params[:fuid]
      else
        params[:provider] = "hooful"
      end
    
          # 3-2. 회원공지(미사용)
      params[:noti] = '{"partice_host":true,"partice_participants":true,"hoo_host":true,"hoo_participants":true,"hootalk_host":true,"hootalk_participants":true,"nday_host":true,"nday_participants":true,"dday_host":true,"dday_participants":true}'
    
          # 3-3. 회원사진 선택

      rn = Random.rand(9).to_i + 1
    defaultcoverpic = "default/default" + rn.to_s + ".jpg"

      # 핸드폰번호 다른계정에서 인증여부 체크
  #		tmp = Smsauth.where('$and' => [{"userid" => params[:userid]},{"phone" => params[:phone]},{"authcode" => params[:authcode]}]).count.to_i
  #		phoneauth = (params[:authresult] == 'success' and params[:authresultn].to_s == params[:phone].to_s and tmp == 1) ? 1 : 0


      #3-4. DB 입력
      create! do |user|
        user.name			= params[:name]
        user.userid			= params[:userid]
        user.password			= Digest::SHA2.hexdigest(params[:password])#params[:password]
        #create 하면서 save 되면 자동으로 save_before 실행되서 password가 두번 암호화됨
        #그래서 무식하지만 하나로 줄여놓은거임
        user.provider			= params[:provider]
        user.uid			= params[:uid]
        user.fuid			= (params[:fuid]) ? params[:fuid] : nil
        user.tuid			= (params[:tuid]) ? params[:tuid] : nil
      user.tid			= (params[:tid]) ? params[:tid] : nil
        user.local		= (params[:local]) ? params[:local] : "없음"

        user.noti			= params[:noti]
        user.userpic		= params[:userpic]
        user.userpicname	= params[:userpicname]
        user.coverpic		= defaultcoverpic
        user.sex 			= params[:sex]

        user.fbauth	= params[:fbauth]
        user.tauth	= params[:tauth]
        user.tsecret	= params[:tsecret] 
      user.phone_auth = 0
      user.acct_auth = 2
      end
    end
    def self.return_screen_name(tuid)
    userdata = open('http://api.twitter.com/1/users/lookup.json?user_id=' + tuid.to_s).read
    userdata = JSON.parse(userdata.to_s)
    return userdata[0]["screen_name"].to_s
  end

  def self.update_screen_name(userid)
    user = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => userid}]).last
    if user.tuid.blank? or user.tuid.empty? or user.tuid.nil?
      user.tuid = nil
    else
      user.tid = Member.return_screen_name(user.tuid).to_s
    end
    user.save
    end
    # 5-4. 회원 연동용 사진 불러오기
    def self.getProfilePictureset(userid)
    @user = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => userid}]).last
    @pSet = Hash.new
    @pSet[:facebook] = "https://graph.facebook.com/"+@user.fuid.to_s+"/picture?type=large&return_ssl_resources=1" if @user.fuid.to_i > 0
    @pSet[:twitter] = "https://api.twitter.com/1/users/profile_image/"+@user.tuid.to_s+"?size=original" if @user.tuid.to_i > 0
    return @pSet
  end

  def self.validateNotification(userid, type)
    user = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => userid}]).last
    if user
      @notify = Hash.new
      @notify = (user.noti.nil?) ? '{"hooful":true,"partice_host":true,"partice_participants":true,"hoo_host":true,"hoo_participants":true,"hootalk_host":true,"hootalk_participants":true,"nday_host":true,"nday_participants":true,"dday_host":true,"dday_participants":true}' : user.noti
      @notify = ActiveSupport::JSON.decode(@notify)
      return @notify["#{type}"]
    else
      return false
    end
  end

  def self.choiceCategory(userid, category)
    user = Member.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => userid}]).last
    if user
      user.category = category
      user.save
      @user_interest = ActiveSupport::JSON.decode(category) unless category.nil?
      LogInterest.savelog(userid,@user_interest)
      return user
    else
      return false
    end
  end

end

