#encoding: UTF-8
class ApiController < ApplicationController
  layout 'api'
  respond_to :json
  
  #0. iPhone
  def getMeet
  	meetlist = Hash.new
  	meetlist[:result] = []
  	@meets = Meet.list(params)
  	@rmeet = []
	@meets.each do |meet|
		@host = User.info(meet[:mHost])
		meet[:mHostPicture] = @host[:picture]
		meet[:mHostName] = @host[:name]
		meet[:mHostCntHost] = 10
		meet[:mHostCntPartice] = 3
		meet[:hooCnt] = 5
		meet[:hooStatus] = 0
		meet[:pCnt] = 0
		meet[:pStatus] = "0"
		@rmeet << meet
	end
	respond_to do |format|
		if @rmeet
			format.json  { render :json => {:result => @rmeet}, :status => :created }
		else
			format.json  { render :json => {:result => "faild"}, :status => :created } #unprocessable_entity
		end
	end
  end

  #1. card_기능_상세(선택) : 모임카드 api
  def card_load
    params[:user_id] = session[:user_id]
    @meets = Meet.list(params)
	  respond_with @meets.to_json
  end

  def community_load
    @meets = Meet.load_community(params)
	  respond_with @meets.to_json
  end

  def person_load
    @persons = User.search_people(params[:page],params[:keyword])
	  respond_with @persons.to_json
  end

  def upload
    if params[:userid] and session[:user_id].nil?
      session[:user_id] = params[:userid]
    end

    if params["uploadFile"]
      @file = Upfile.fileUpload(params["uploadFile"],params["userid"],params["uploadPath"])
      session[:user_id] = params[:userid] if params[:userid] and session[:user_id].nil?
    else
      @file = Hash.new
      @file[:vname] = nil
      @file[:name] = nil
    end
  end

  def user_meet
	case params[:type]
		when "participated"
			@meets = Meet.list_participated(params)
		when "hosted"
			@meets = Meet.list_hosted(params)
		when "hooed"
			@meets = Meet.list_hooed(params)
	end
	respond_with @meets.to_json
  end

  def valid_meet
    @meets = Meet.mCodeValid(params[:mcode])
    render:json =>{:count => @meets}
  end
  
  def manage_meet
  	@meets = Meet.manage_meet(params)
	respond_with @meets.to_json
  end
  
  def manage_count_meet
  	@meets = Meet.manage_count_meet(params)
	respond_with @meets.to_json
  end

  def user_state
	case params[:type]
		when "checkup"
			@state = TicketSold.checkUp(params)
		when "checkdown"
			@state = TicketSold.checkDown(params)
		when "stateup"
			@state = Hoopartice.stateUp(params)
		when "statedown"
			@state = Hoopartice.stateDown(params)
		when "delete"
	end
	respond_with @state.to_json
  end

#dropsns
  def dropsns
  	mOriginPicture = ''
    if session[:user_id] && params[:provider]
		user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => session[:user_id]}]).last
		if params[:provider] == 'twitter'
			user.uid = nil
			user.tuid = nil
			user.tauth = nil
			user.tsecret = nil
			if user.userpic == 'twitter'
				user.userpic = 'hooful'
			else
				mOriginPicture = user.userpic
			end
			#user.tid = nil
		elsif params[:provider] == 'facebook'
			user.uid = nil
			user.fuid = nil
			user.fbauth = nil
			user.userpic = 'hooful' if user.userpic == 'facebook'
		end
      
		respond_to do |format|
			if user.save
				format.json { render :json => {:result => "success", :origin => mOriginPicture}}
			else
				format.json { render :json => {:result => "fail"}}
			end
		end
	else
		render :json => {:result => "fail"}
    end
  end

  def reopen
	if params[:category]
	    @emeet = Meet.where(:mHost => params[:mHost], :mCategory => params[:category])
	else
		@emeet = Meet.where(:mHost => params[:mHost])
	end
    @meets = []
    @emeet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mCategory"] = meet.mCategory
      mtmp["mTitle"] = meet.mTitle
      mtmp["mPlace"] = meet.mPlace
      mtmp["mAddress"] = meet.mAddress
      mtmp["mLat"] = meet.mLat.to_f
      mtmp["mLng"] = meet.mLng.to_f
      mtmp["mPrice"] = meet.mPrice
      mtmp["mDescription"] = meet.mDescription
      mtmp["mPicture"] = meet.mPicture
      mtmp["mPicturename"] = meet.mPicturename
      mtmp["mPayUse"] = meet.mPayUse
      mtmp["mPaytype"]		= meet.mPaytype
      mtmp["mTicket"]	 = []
      @eticket = Ticket.where(:mCode => meet.mCode)
      @eticket.each do |ticket|
        ttmp = Hash.new
        ttmp["tName"]	= ticket.tName
        ttmp["tQuantity"]	= ticket.tQuantity
        ttmp["tPrice"]	= ticket.tPrice
        ttmp["tDescription"]	= ticket.tDescription
        mtmp["mTicket"]	<< ttmp
      end
      @meets << mtmp
    end
    respond_with @meets.to_json
  end

  def company

	today = Date.today
    @emeet = Meet.where(:mCategory => params[:company], :mDateE.gte => today).desc(:mView).asc(:mDateS)
    @meets = []
    @emeet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mCategory"] = meet.mCategory
      mtmp["mTitle"] = meet.mTitle
      mtmp["mPlace"] = meet.mPlace
      mtmp["mAddress"] = meet.mAddress
      mtmp["mLat"] = meet.mLat.to_f
      mtmp["mLng"] = meet.mLng.to_f
      mtmp["mPrice"] = meet.mPrice
      mtmp["mDescription"] = meet.mDescription
      mtmp["mPicture"] = meet.mPicture
      mtmp["mPicturename"] = meet.mPicturename
      mtmp["mPayUse"] = meet.mPayUse
      mtmp["mPaytype"]		= meet.mPaytype
      mtmp["mTicket"]	 = []
      @eticket = Ticket.where(:mCode => meet.mCode)
      @eticket.each do |ticket|
        ttmp = Hash.new
        ttmp["tName"]	= ticket.tName
        ttmp["tQuantity"]	= ticket.tQuantity
        ttmp["tPrice"]	= ticket.tPrice
        ttmp["tDescription"]	= ticket.tDescription
        mtmp["mTicket"]	<< ttmp
      end
      @meets << mtmp
    end
    respond_with @meets.to_json
  end

  def withdrawmeet
    @emeet = Meet.where(:mHost => params[:mHost])
    @meets = []
    mtmp = Hash.new
    mtmp["mTitle"] = "전체활동"
    mtmp["mCode"] = ""
    @meets << mtmp
    
    @emeet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mCategory"] = meet.mCategory
      mtmp["mTitle"] = meet.mTitle
      @meets << mtmp
    end
    respond_with @meets.to_json
  end

  def withdrawinfo
    if params[:mCode]
      @emeet = Meet.where(:mHost => params[:mHost], :mCode => params[:mCode])
    else
      @emeet = Meet.where(:mHost => params[:mHost])
    end
    @meets = Hash.new
    @meets[:accSales] = 0
    @meets[:accUse] = 0
    @meets[:accSalesPrice] = 0
    @meets[:accRefundEnd] = 0
    @meets[:accRefunding] = 0
    @meets[:accRefund] = 0
    @emeet.each do |meet|
      ticket_sold = TicketSold.where(:mCode => meet.mCode)
      #ticket_use = TicketSold.where(:mCode => meet.mCode, :tUse => 1)
      #price_sold = TicketSold.where(:mCode => meet.mCode).sum(:tPrice)
      #price_end = TicketSold.where(:mCode => meet.mCode, :tState => 3).sum(:tPrice)
      #price_ing = TicketSold.where(:mCode => meet.mCode, :tState => 2).sum(:tPrice)
      #price_wait = TicketSold.where(:mCode => meet.mCode, :tState => 1).sum(:tPrice)

      ticket_sold.each do |tsold|
        @meets[:accSales] += 1
        @meets[:accUse] += 1 if tsold.tUse == 1
        @meets[:accSalesPrice] += tsold.tPrice
        case tsold.tState
          when 1
            @meets[:accRefund] += tsold.tPrice
          when 2
            @meets[:accRefunding] += tsold.tPrice
          when 3
            @meets[:accRefundEnd] += tsold.tPrice
        end
      end

      #@meets[:accSales] += ticket_sold.count
      #@meets[:accUse] += ticket_use.count
      #@meets[:accSalesPrice] += price_end + price_ing + price_wait
      #@meets[:accRefundEnd] += price_end
      #@meets[:accRefunding] += price_ing
      #@meets[:accRefund] += price_wait
    end
    respond_with @meets.to_json
  end

  def code_search
    @code = TicketSold.searchCode(params)
    respond_with @code.to_json
  end

  def code_use
    @code = TicketSold.useCode(params)
    respond_with @code.to_json
  end

#export xls
#http://cafe.hooful.com/api/xls_participants.xls?mCode=webtech3rd
  def xls_participants
    @meet = Meet.where(mCode: params[:mCode]).first
    @p_partice = []
    @p_person = @meet.participants
    @p_person.each do |person|
      person["uHost"] = User.info(person[:mUserid])
      @p_partice << person
    end
    @p_watting = []
    @w_person = @meet.watings
    @w_person.each do |person|
      person["uHost"] = User.info(person[:mUserid])
      @p_watting << person
    end
    @p_partice_c = @p_partice.count
    @p_watting_c = @p_watting.count
    
    respond_to do |format|
      format.xls
    end
  end
#http://cafe.hooful.com/api/xls_sales.xls?mCode=test12345
  def xls_sales
    @meet = Meet.where(mCode: params[:mCode]).first
    @sales = Hoopartice.saleTicket(params)
    @sales_c = @sales.count
    respond_to do |format|
      format.xls
    end
  end
# 방명록에서 공통 활동 찾기

  def commonmeet
    @host_partice = Hoopartice.where(:mUserid => params[:hostid])
    @guest_partice = Hoopartice.where(:mUserid => params[:guestid])
	
	#1. host partice
	@host_meet = Meet.where(:mHost => params[:hostid], :mCode.in => @guest_partice.map(&:mCode))
	#2. partice host
	@guest_meet = Meet.where(:mHost => params[:guestid], :mCode.in => @host_partice.map(&:mCode))
	
	
	#3. partice partice
	
	@both_meet = Meet.where(:mCode.in => @host_partice.map(&:mCode)).any_in(mCode: @guest_partice.map(&:mCode))

	@meets = []
	@host_meet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mTitle"] = meet.mTitle
      mtmp["mCategory"] = meet.mCategory
      @meets << mtmp
    end
	@guest_meet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mTitle"] = meet.mTitle
      mtmp["mCategory"] = meet.mCategory
      @meets << mtmp
    end
	@both_meet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mTitle"] = meet.mTitle
      mtmp["mCategory"] = meet.mCategory
      @meets << mtmp
    end
    respond_with @meets.to_json
  end


# 15. 인증문자 발송 및 체크 시작
	# 15-1. 인증문자 발송
	def authcodesend
		user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => params[:userid]}]).last
		phonecnt = User.count(:conditions => ["phone = ? and phone_auth = ?",params[:phone], 1]).to_i
		if phonecnt == 0 or (phonecnt == 1 and user.phone.to_s != params[:phone])
			authcode = Smsauth.create_authcode(params[:userid], params[:phone], params[:type])
			if authcode == 'empty' or params[:userid].nil? or params[:userid].blank? or params[:userid].empty? or params[:phone].nil? or params[:phone].blank? or params[:phone].empty?
				respond_to do |format|
					format.json { render :json => {:result => "failed"}, :status => :created }
				end
			else
				params[:senddate] = 'now'
				params[:msg] = "[Hooful] :: 인증번호 : " + authcode.to_s + " 본 인증번호는 5분간 유효합니다."
				Home.smssend(params)
				respond_to do |format|
					format.json { render :json => {:result => "success"}, :status => :created }
				end			
			end
		else
			respond_to do |format|
				format.json { render :json => {:result => "exist"}}
			end
		end
	end
	# 15-2. 인증문자 체크
	def authcodecheck
		if params[:phone].nil? or params[:phone].blank? or params[:phone].empty? or params[:authcode].nil? or params[:authcode].blank? or params[:authcode].empty?
			respond_to do |format|
				format.json { render :json => {:result => "failed"}, :status => :created }
			end
		else
			if Smsauth.smsauth_check(params[:userid], params[:phone], params[:authcode])
				if params[:type] == "join"
          respond_to do |format|
            format.json { render :json => {:result => "success"}, :status => :created }
          end
        else
          user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => params[:userid]}]).last
          user.phone = params[:phone]
          user.phone_auth = 1
          if user.save
            respond_to do |format|
              format.json { render :json => {:result => "success"}, :status => :created }
            end
          else
            respond_to do |format|
              format.json { render :json => {:result => "failed"}, :status => :created }
            end
          end
        end
			else
				respond_to do |format|
					format.json { render :json => {:result => "failed"}, :status => :created }
				end
			end
		end
	end
# // 15. 인증문자 발송 및 체크 끝

  def setCategory
    @user = User.choiceCategory(params[:userid], params[:category])
    if @user
      case params[:userpicCopy]
        when "/userpic/noimage.png"
          @user.userpic = "hooful"
        when "hooful"
          @user.userpic = "hooful"
        when "twitter"
          @user.userpic = "twitter"
        when "facebook"
          @user.userpic = "facebook"
      end
      
      session[:user_id] = @user.userid
      respond_to do |format|
        format.json { render :json => {:result => "success"}, :status => :created }
      end
    else
      respond_to do |format|
        format.json { render :json => {:result => "failed"}, :status => :created }
      end
    end
  end

  def totalCount
    @result = Meet.allCount
    respond_to do |format|
      format.json { render :json => @result, :status => :created }
    end
  end

#6. 활동코드 중복검사
	def chkMeetcode
		if params[:mOrigincode] && params[:mCode] == params[:mOrigincode]
			respond_to do |format|
				format.json  { render :json => true, :status => :created }
				end
		else
			@chkMeet = Meet.where(mCode: params[:mCode]).count

			respond_to do |format|
				if @chkMeet != 0
					format.json  { render :json => false, :status => :created }
				else
					format.json  { render :json => true, :status => :created } #unprocessable_entity
				end
			end
		end
	end
#7. 회원아이디 중복검사
	def chkUserid
		@user = User.find(:all, :conditions => ['userid = :userid AND acct_auth > 0', {:userid => params[:userid]}]).last

		respond_to do |format|
			if @user
				format.json  { render :json => false, :status => :created }
			else
				format.json  { render :json => true, :status => :created } #unprocessable_entity
			end
		end
	end
#8. 휴대전화 중복검사
	def chkUserphone
		@user = User.find(:all, :conditions => ['phone = :phone AND acct_auth > 0', {:phone => params[:phone]}]).last

		respond_to do |format|
			if @user
				format.json  { render :json => false, :status => :created }
			else
				format.json  { render :json => true, :status => :created } #unprocessable_entity
			end
		end
	end

# 티켓
  def sale_ticket
	  @sales = TicketSold.saleTicket(params)
	  respond_with @sales.to_json
  end
  def sale_state_ticket
	  @sales = TicketSold.saleTicketState(params)
	  respond_with @sales.to_json
  end
  def sale_state_ticket_count
	  @sales = TicketSold.saleTicketStateCount(params)
	  respond_with @sales.to_json
  end
  def withdraw_ticket
	  @sales = TicketSold.withdrawTicket(params)
	  respond_with @sales.to_json
  end
  def withdraw_calcurate
	  @sales = TicketSold.withdrawCalcurate(params)
    respond_to do |format|
      format.json { render :json => @sales, :status => :created }
    end
  end

  def cheap_ticket
    @result = Ticket.cheap_ticket(params)
    respond_to do |format|
      format.json { render :json => @result, :status => :created }
    end
  end

  def ticketlist
    @result = TicketSold.listTicket(session[:user_id])
    respond_to do |format|
      format.json { render :json => @result, :status => :created }
    end
  end
  def groupcount
    @group_count = Group.where(mCode: params[:mCode]).count	
    render :json => {:result => @group_count}
  end
  def group_category
	group_member = GroupMember.where(:mUserid => params[:mUserid])
	if group_member
	  group = Group.where(:_id.in => group_member.map(&:group_id)).any_of(:gCategory => params[:gCategory]).first
	  
		if group and !group.mCode.blank?
			meetinfo = Meet.where(:mCode => group.mCode).first
			group[:company_title] = meetinfo.mTitle
			group[:company_image] = meetinfo.mPicture
			group[:company_price] = meetinfo.card_price
			hostinfo = User.where(:userid => meetinfo.mHost).first
			group[:host_name] = hostinfo.name
			group[:host_picture] = hostinfo.picture
			group[:host_link] = hostinfo.link
			group[:host_members] = hostinfo.members
		end
	end
	respond_with group
  end
  def meet_group
    if params[:userid] == "hooful@hooful.com"
      render :json => {:result => true }
    else
      render :json => {:result => TicketSold.where(:mCode => params[:mcode], :mUserid => params[:userid], :tState.ne => 7).exists?}
    end
  end

  def chkCountTicketsold
    @ticket = TicketSold.chkCountTicketsold(params)
    render :json => {:result => @ticket}
  end

  def choiceTicket
    @ticket = TicketSold.choiceTicket(params[:mUserid], params[:mCode])    
    respond_with @ticket
  end

  def reservCode
    @ticket = TicketSold.reservCode(params)    
    respond_with @ticket
  end

  def changeState
    @ticket = TicketSold.changeState(params)    
    respond_with @ticket
  end

  def detailTicketCode
    @ticket = TicketSold.detailTicketCode(params[:tCode])
    respond_with @ticket
  end

  def getWithdraw
    @ticket = Withdraw.getWithdraw(params)    
    respond_with @ticket
  end

  def getWithdrawDetail
    @ticket = Withdraw.getWithdrawDetail(params)    
    respond_with @ticket
  end

#포인트

  def changePoint
    @point = User.changePoint(params[:type], params[:point], params[:user])
    respond_with @point
  end

  def socket
	
  end

#plugin

  def pluginChkUrl
    @hoocnt = Hoolike.hoocounturl(params[:mUrl], params[:mUserid])
    respond_with @hoocnt
  end

  def pluginChkCode
    @hoocnt = Hoolike.hoocountcode(params[:mCode], params[:mUserid])
    render :json => @hoocnt
  end

  def pluginAddLike
    @hoolike = Hoolike.create_hoolike(params)
    @hoocnt = Hoolike.hoocounturl(params[:mUrl], params[:mUserid])
    respond_with @hoocnt
  end

  def pluginDelLike
    @hoolike = Hoolike.delhoolike(params)
    respond_with @hoolike
  end

  def pluginMeetAddLike
    @hoolike = Hoolike.create_hoolike(params)
    @hoocnt = Hoolike.hoocountcode(params[:mCode], params[:mUserid])
    render :json => @hoocnt
  end

  def pluginMeetDelLike
    @hoolike = Hoolike.delhoolike(params)
    render :json => @hoolike
  end

  def comment_edit
    @userinfo = User.find_by_userid(params[:userid])
	@userinfo.comment = params[:comment]
	@userinfo.save

    respond_with @userinfo
  end

  def participants
	partice_limit = 9
	#1. group member
	groupall = Group.where(:mCode => params[:mCode])
	group_member = GroupMember.where(:group_id.in => groupall.map(&:_id))
	@group_member = []
	@group_member_check = Hash.new
	group_member.each do |member|
		@group_member << member.mUserid
		@group_member_check["#{member.mUserid}"] = 1
	end
	#2. ticket buyer
	ticket_buyer = TicketSold.where(:mCode => params[:mCode], :tState => 1)
	@ticket_buyer = []
	@ticket_buyer_check = Hash.new
	ticket_buyer.each do |buyer|
		@ticket_buyer << buyer.mUserid
		@ticket_buyer_check["#{buyer.mUserid}"] = 1
	end
	#@participants = Member.any_of({:userid.in => @group_member.map(&:mUserid)},{:userid.in => @ticket_buyer.map(&:mUserid)})
	@participants = User.find(:all, :conditions => ["userid IN (?) or userid IN (?)", @ticket_buyer, @group_member])
	start = 0
	start = params[:size].to_i if params[:size]
	@particelist = []
	@participants[start..(start+partice_limit-1)].each do |partice|
		mtmp = Hash.new
		mtmp["userid"] = partice.userid
		mtmp["picture"] = partice.picture
		mtmp["name"] = partice.name
		mtmp["link"] = Home.encode(partice.userid)
		mtmp["ticket"] = 0
		mtmp["group"] = 0
		mtmp["ticket"] = 1 if @ticket_buyer_check["#{partice.userid}"]
		mtmp["group"] = 1 if @group_member_check["#{partice.userid}"]
		@particelist << mtmp
	end

	if @participants.count > (params[:size].to_f + partice_limit)
		mtmp = Hash.new
		mtmp["next"] = @participants.count-partice_limit
		@particelist << mtmp
	end
    respond_with @particelist
  end

  def fbevent
    @fb = Hash.new
    @fb[:type] = params[:type]
    @fb[:userid] = params[:userid]
    @fb[:fuid] = params[:fuid]
    @fb[:feed_id] = params[:feed_id].split('_')[1] if params[:feed_id]
    @fb[:friends] = params[:friends]
    @fb[:friends_cnt] = params[:friends].split(',').count if params[:friends]
    @fb[:point] = (params[:type] == "100") ? 60 : @fb[:friends_cnt] * 40
    @event = Fbevent.create_event(@fb)
    respond_with @event
  end
  
  def dong_search
  	@zipcode = Zipcode.search_dong(params[:dong])
  	respond_with @zipcode
  end
  
# 13. 에디터 사진 업로드
  def editorupload
  
		filejs = Hash.new
		filejs[:vname] = nil
		filejs[:sessionuseridcheck] = (session[:user_id].nil?) ? "NONE" : session[:user_id]
		filejs[:filelink] = nil
		url = nil

		filejs[:sessionuseridcheck] += (session[:user_id].nil?) ? "NONE" : session[:user_id].to_s

		if params[:file]
			@@BUCKET = "hoofulimg"

			AWS::S3::DEFAULT_HOST.replace "s3-ap-northeast-1.amazonaws.com" 
			AWS::S3::Base.establish_connection!(
				:access_key_id     => 'AKIAIKNA32CMDL6KU2RA',
				:secret_access_key => 'HlKnKA9/etPNVOsAxFww/57YgGDDm9nYCURGjXnu'
			)
			fileUp = params[:file]
			orig_filename =  fileUp.original_filename
			real_name = orig_filename.split(".")
			time_now = Time.now
			time_now = time_now.strftime("%Y%m%d%H%M%S%L").to_s
			filename = "#{time_now}_s3.#{real_name.last.downcase}"

			AWS::S3::S3Object.store(filename, fileUp.read, @@BUCKET + "/editorpic", :access => :public_read)
			url = AWS::S3::S3Object.url_for(filename, @@BUCKET + "/editorpic", :authenticated => false)

      session[:user_id] = params[:userid] if params[:userid] and session[:user_id].blank?
		end

		if url
			filejs[:filelink] = url
		else
			filejs[:filelink] = "/editorpic/none.png"
		end
		session[:user_id] = params[:userid]

		render :text => filejs.to_json
	
  end

  def olist
    respond_with TicketSold.detailTicket(params[:tid])
  end

  def oticket
    respond_with TicketSold.listGroupTicketAll(params[:user], params[:id])
  end

  def cert_auth
=begin
  	@userinfo = User.info(params[:userid])
  	if @userinfo.cert_auth == 1
		render :json =>  {:result => "true"}
	else
		render :json =>  {:result => "faild"}
	end
=end
	render :json =>  {:result => "true"}
  end
  def reviewmeet
  	if params[:mHost] == "hooful@hooful.com"
      if params[:category]
          @emeet = Meet.where(:mCategory => params[:category])
      else
          @emeet = Meet.all
      end
    else
        @ticket = TicketSold.where(:mUserid => params[:mHost], :tState.in => [9,10])	
    
      if params[:category] != ""
          @emeet = Meet.where(:mCode.in => @ticket.map(&:mCode), :mCategory => params[:category])
      else
          @emeet = Meet.where(:mCode.in => @ticket.map(&:mCode))
      end
    end
    @meets = []
    @emeet.each do |meet|
      mtmp = Hash.new
      mtmp["mCode"] = meet.mCode
      mtmp["mCategory"] = meet.mCategory
      mtmp["mTitle"] = meet.mTitle
      mtmp["mPlace"] = meet.mPlace
      mtmp["mAddress"] = meet.mAddress
      mtmp["mLat"] = meet.mLat.to_f
      mtmp["mLng"] = meet.mLng.to_f
      mtmp["mPrice"] = meet.mPrice
      mtmp["mDescription"] = meet.mDescription
      mtmp["mPicture"] = meet.mPicture
      mtmp["mPicturename"] = meet.mPicturename
      mtmp["mPayUse"] = meet.mPayUse
      mtmp["mPaytype"]		= meet.mPaytype
      mtmp["mTicket"]	 = []
      @eticket = Ticket.where(:mCode => meet.mCode)
      @eticket.each do |ticket|
        ttmp = Hash.new
        ttmp["tName"]	= ticket.tName
        ttmp["tQuantity"]	= ticket.tQuantity
        ttmp["tPrice"]	= ticket.tPrice
        ttmp["tDescription"]	= ticket.tDescription
        mtmp["mTicket"]	<< ttmp
      end
      @meets << mtmp
    end
    render :json => @meets.to_json
  end

 def likelist
 	@hoolike = Hoolike.hoolikeurl(params[:url]).desc(:created_at).limit(10)
 	@likelist = Array.new
 	@hoolike.each do |likemember|
 		userinfo = User.info(likemember.mUserid)
 		utmp = Hash.new
 		utmp[:link] = userinfo.link
 		utmp[:picture] = userinfo.picture
 		utmp[:name] = userinfo.name
 		utmp[:members] = userinfo.members
 		utmp[:userid] = userinfo.userid
 		@likelist << utmp
 	end
 	respond_with @likelist
 end

 def hostinfo
    @user = Meet.list(params)
    respond_with @user
 end

 def mypeople
  data = Hash.new
  data[:apikey] = "2d28a049e7697de9319f9b5d0cdecc5ce246212c"
  request = Rack::Request.new(env)
  params[:daumaction] = request.params['action']

  arrLunch = ["도원가자","육팀장가자","맛소갈래?","밥마니 먹을까?","양팔출 가자.","순대국이 땡긴다.","멀지만 시골밥상!!","왕밥상 떡볶이 먹으러 갑시다.","육교 건너서 우렁쌈밥?","7분 돼지김치는 너무 멀겠지?"]

  case params[:daumaction]
    when "addBuddy"
      data[:daumaction] = params[:daumaction]
		  data[:buddyId] = params[:buddyId]
		  data[:content] = "반가워요. 후풀과 재미있게 놀아봅시다!!\n\n<후풀봇 명령어>\n\n- 점심시간 근처 식당 정하기\n  (밥먹자,배고파,밥줘)"
      
      @mypeople = Home.mpSend(data)
    when "createGroup"
      data[:daumaction] = params[:daumaction]
		  data[:buddyId] = params[:buddyId]
		  data[:groupId] = params[:groupId]
		  data[:content] = "반가워요. 후풀과 재미있게 놀아봅시다!!\n\n<후풀봇 명령어>\n\n- 점심시간 근처 식당 정하기\n  (밥먹자,배고파,밥줘)"

      @mypeople = Home.mpSendGroup(data)
    when "helpFromMessage"
      data[:daumaction] = params[:daumaction]
		  data[:buddyId] = params[:buddyId]
		  data[:content] = "<후풀봇 명령어>\n\n- 점심시간 근처 식당 정하기\n  (밥먹자,배고파,밥줘)"
      
      @mypeople = Home.mpSend(data)
    when "helpFromGroup"
      data[:daumaction] = params[:daumaction]
		  data[:buddyId] = params[:buddyId]
		  data[:groupId] = params[:groupId]
		  data[:content] = "<후풀봇 명령어>\n\n- 점심시간 근처 식당 정하기\n  (밥먹자,배고파,밥줘)"
      
      @mypeople = Home.mpSendGroup(data)
    when "sendFromMessage"
      data[:daumaction] = params[:daumaction]
		  data[:buddyId] = params[:buddyId]
		  data[:content] = params[:content]

      txtToday = "/오늘 몇일"
      if params[:content] =~ /#{Regexp.quote(txtToday)}/
        data[:content] = Time.now.strftime("%Y년 %m월 %d일")
      end
      if (params[:content] =~ /#{Regexp.quote("배고파")}/) or (params[:content] =~ /#{Regexp.quote("밥먹자")}/) or (params[:content] =~ /#{Regexp.quote("밥줘")}/)
        data[:content] = arrLunch.sample(1)
      end
      if (params[:content] =~ /#{Regexp.quote("워크샵")}/) and params[:content] =~ /#{Regexp.quote("언제")}/
        data[:content] = "8월 15일에서 18일 사이에 갈껍니다."
      end
      
      @mypeople = Home.mpSend(data)
    when "sendFromGroup"
      data[:daumaction] = params[:daumaction]
		  data[:buddyId] = params[:buddyId]
		  data[:groupId] = params[:groupId]
		  data[:content] = params[:content]
      
      @mypeople = Home.mpSendGroup(data)
  end
  respond_with data
 end

 def weather
  data = Hash.new
  data[:apikey] = "1857cd089ac141d079ba5f6583558849d3c09acd"
  data[:query] = "Show datasources;"
  data["Content-Type"] = "application/x-www-form-urlencoded"

  url = URI.parse('http://apis.daum.net')
	http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Get.new("/sensorql/?q="+data[:query]+"&apiket="+data[:apikey])
  res = http.request(request)

  respond_with res.inspect
 end

end
