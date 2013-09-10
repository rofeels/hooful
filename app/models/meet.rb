#encoding: utf-8
include ActionView::Helpers::NumberHelper #number_to_currency

class Meet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Spacial::Document
  field :mCode, type: String
  field :mHost, type: String
  field :mTitle, type: String
  field :mDate, type: String
  field :mDateS, type: DateTime
  field :mDateE, type: DateTime
  field :mTimeS, type: Float
  field :mTimeE, type: Float
  field :mPlace, type: String
  field :mAddress, type: String
  field :mLocation, type: Array, spacial: {lat: :latitude, lon: :longitude, return_array: true }
  field :mLat, type: String
  field :mLng, type: String
  field :mPrice, type: Integer
  field :mPayUse, type: Integer
  field :mPaytype, type: String
  field :mHolder, type: String
  field :mAccount, type: String
  field :mDescription, type: String
  field :mPicture, type: String 
  field :mCategory, type: String
  field :mSummary, type: String 
  field :mPicture, type: String
  field :mPicturename, type: String
  field :mView, type: Integer # 2=먼저보이기, 0/NIL=안보이기, 1 = 기본보이기
  field :mExternal, type: Integer
  field :mLink, type: String
  field :host, type: Hash
  field :card_time, type: String
  field :card_price, type: String
  field :card_origin_price, type: String
  field :uHoo, type: Integer
  field :uCmtcnt, type: Integer
  field :uFemale, type: Integer
  field :uMale, type: Integer
  field :mFemale, type: Integer
  field :mMale, type: Integer

  validates_presence_of :mCode, :mCategory, :mTitle, :mDescription, :mPicture, :mDate, :mTimeS, :mPlace, :message => "is empty"
  validates_uniqueness_of :mCode
  validates_numericality_of :mTimeS

  CARDNUM = 28
   
  def self.mCodeValid(mCode)
  	meet = Meet.where(:mCode => mCode).count
  end

  def self.allCount
    Meet.where(:mView.gt => 0).count
  end
  
  def self.create_meet(params)
  	meet = Meet.new
	meet.mCode 			= params[:mCode]
	meet.mCategory		= params[:mCategory]
	meet.mHost			= params[:mHost]
	meet.mTitle			= params[:mTitle]
	meet.mDate			= params[:mDate]

	datese = Meet.dateSE(params[:mDate])
	meet.mDateS			= datese[0]
	meet.mDateE			= datese[1]

	meet.mTimeS			= params[:mTimeS]
	meet.mTimeE			= params[:mTimeE]
	meet.mPlace			= params[:mPlace]
	meet.mAddress		= params[:mAddress]	
	meet.mLocation		= [params[:mLat].to_f, params[:mLng].to_f]	# mLocation은 앱에서 near 검색할때만 쓰임
	meet.mLat 			= params[:mLat].to_f	# mLat, mLng은 모바일에서 각 카드 좌표 찍을때도 쓰임
	meet.mLng 			= params[:mLng].to_f
	meet.mPrice			= params[:mPrice]
	meet.mDescription	= params[:mDescription]
	meet.mSummary	= params[:mSummary]
	meet.mPicture		= params[:mPicture]
	meet.mPicturename	= params[:mPicturename]
	meet.mPayUse		= params[:mPayUse]
	if params[:mPayUse] == "1"
	meet.mPaytype		= "card" if params[:mPaytype]["card"] =="1"
	meet.mPaytype		+= ", 801" if params[:mPaytype]["801"] =="1"
	meet.mPaytype		+= ", 4" if params[:mPaytype]["4"] =="1"
	end
	meet.mView 			= 1
  meet.uHoo = 0
  meet.uCmtcnt = 0
  meet.uFemale = 0
  meet.uMale = 0	
  meet.mFemale = params[:mFemale]
  meet.mMale = params[:mMale]
	
	if meet.valid?
		meet.save
	else
		returnmsg = ""
		meet.errors.full_messages.each do |msg|
			returnmsg += msg+"\n"
		end
		returnmsg
	end
  end
  
  def self.update_meet(params)
  	meet = Meet.where(:mCode => params[:mCode]).first
	meet.mCode			= params[:mCode]
	meet.mCategory		= params[:mCategory]
	meet.mHost			= params[:mHost]
	meet.mTitle			= params[:mTitle]
	meet.mDate			= params[:mDate]

	datese = Meet.dateSE(params[:mDate])
	meet.mDateS			= datese[0]
	meet.mDateE			= datese[1]
	
	meet.mTimeS			= params[:mTimeS]
	meet.mTimeE			= params[:mTimeE]
	meet.mPlace			= params[:mPlace]
	meet.mAddress		= params[:mAddress]	
	meet.mLocation		= [params[:mLat].to_f, params[:mLng].to_f]	# mLocation은 앱에서 near 검색할때만 쓰임
	meet.mLat 			= params[:mLat].to_f	# mLat, mLng은 모바일에서 각 카드 좌표 찍을때도 쓰임
	meet.mLng 			= params[:mLng].to_f
	meet.mPrice			= params[:mPrice]
	meet.mDescription	= params[:mDescription]
	meet.mSummary	= params[:mSummary]
	meet.mPicture		= params[:mPicture]
	meet.mPicturename	= params[:mPicturename]
	meet.mPayUse		= params[:mPayUse]
	if params[:mPayUse] == "1"
	meet.mPaytype		= "card" if params[:mPaytype]["card"] =="1"
	meet.mPaytype		+= ", 801" if params[:mPaytype]["801"] =="1"
	meet.mPaytype		+= ", 4" if params[:mPaytype]["4"] =="1"
	end
  meet.mFemale = params[:mFemale]
  meet.mMale = params[:mMale]
	
	if meet.valid?
		meet.save
	else
		returnmsg = ""
		meet.errors.full_messages.each do |msg|
			returnmsg += msg+"\n"
		end
		returnmsg
	end
  end
  
  def self.list(params)
	params[:page] ||= 1
	params[:order] ||= 'date'
	today = Date.today.strftime('%Y-%m-%d')
	today = Date.today.to_time.to_i 

	@arrayS = Array.wrap(nil)
	@arrayS += Array.wrap("mTitle" => /.*#{params[:keyword]}.*/)
	@arrayS += Array.wrap("mDescription" => /.*#{params[:keyword]}.*/)
	@arrayS += Array.wrap("mPlace" => /.*#{params[:keyword]}.*/)

	@emeet = Meet.where("$or" => @arrayS).all_of(:mView.gte => 0).asc(:mView).asc(:mDateE).skip(CARDNUM * (params[:page].to_i - 1)).limit(CARDNUM)
=begin
	case params[:order]
		when "date"
			@emeet = Meet.where("$or" => @arrayS).all_of(:mDateE.gte => today).desc(:mView).asc(:mDate).skip(CARDNUM * (params[:page].to_i - 1)).limit(CARDNUM)
		when "popular"
			@emeet = Meet.where("$or" => @arrayS).all_of(:mDateE.gte => today).desc(:mView).asc(:mDate).skip(CARDNUM * (params[:page].to_i - 1)).limit(CARDNUM)
		when "duedate"
			@emeet = Meet.where("$or" => @arrayS).all_of(:mDateE.gte => today).asc(:mView).desc(:mDate).limit(CARDNUM)
	end
	
	@meet = []
	@emeet.each do |meet|
		@mHost = meet.host
		meet["card_date"] = meet.card_date
		meet["card_time"] = meet.card_time
		meet["card_price"] = meet.card_price
		meet["hoo"] = meet.hoo
		meet["hUserid"] = @mHost.userid
		meet["hName"] = @mHost.name
		meet["hMembers"] = @mHost.members
		meet["hPicture"] = @mHost.picture

		@meet << meet
	end  
=end

	@emeet
  end

  def self.list_participated(params)
	params[:page] ||= 1
	params[:order] ||= 'date'
	today = Date.today.strftime('%Y-%m-%d')
	
	partice = Hoopartice.where(mUserid: params[:userid])
	@emeet = Meet.where(:mCode.in => partice.map(&:mCode)).asc(:mView).asc(:mDateE).skip(CARDNUM * (params[:page].to_i - 1)).limit(@ARDNUM)
	
	@meet = []
	@emeet.each do |meet|
		@mHost = meet.host
		meet["card_date"] = meet.card_date
		meet["card_time"] = meet.card_time
		meet["card_price"] = meet.card_price
		meet["card_place"] = meet.card_place
        meet["meet_group"] = meet.meet_group
		meet["hoo"] = meet.hoo
		meet["hUserid"] = @mHost.userid
		meet["hName"] = @mHost.name
		meet["hMembers"] = @mHost.members
		meet["hPicture"] = @mHost.picture

		@meet << meet
	end

	@meet
  end

  def self.list_hooed(params)
    params[:page] ||= 1
    params[:order] ||= 'date'
    today = Date.today.strftime('%Y-%m-%d')
    
    hoo = Hoolike.where(mUserid: params[:userid])
    @emeet = Meet.where(:mCode.in => hoo.map(&:mCode)).desc(:mDate).skip(CARDNUM * (params[:page].to_i - 1)).limit(CARDNUM)
    
    @meet = []
    @emeet.each do |meet|
      @mHost = meet.host
      meet["card_date"] = meet.card_date
      meet["card_time"] = meet.card_time
      meet["card_price"] = meet.card_price
      meet["card_place"] = meet.card_place
      meet["meet_group"] = meet.meet_group
      meet["hoo"] = meet.hoo
      meet["hUserid"] = @mHost.userid
      meet["hName"] = @mHost.name
      meet["hMembers"] = @mHost.members
      meet["hPicture"] = @mHost.picture

      @meet << meet
    end

    @meet
  end
  
  def self.load(mCode)
    @meet = Meet.where(mCode: mCode).first
    category = @meet.mCategory.split(",")
    category_name = Interest.where(:code => category[0]).first
    @meet[:mCategoryname] = ""
    @meet[:mCategoryname] = category_name[:name] if category_name
    @meet[:mCategoryactive] = category_name[:active] if category_name
    @meet
  end
  
  def self.load_community(params)
    params[:page] ||= 1
    params[:order] ||= 'date'
    params[:cardnum] ||= CARDNUM
    today = Date.today.strftime('%Y-%m-%d')
    @emeet = Meet.where(mCategory: params[:mCategory]).desc(:mDate).skip(params[:cardnum].to_i * (params[:page].to_i - 1)).limit(params[:cardnum].to_i)
    
    @meet = []
    @emeet.each do |meet|
      @mHost = meet.host
      meet["card_date"] = meet.card_date
      meet["card_time"] = meet.card_time
      meet["card_price"] = meet.card_price
      meet["card_place"] = meet.card_place
      meet["meet_group"] = meet.meet_group
      meet["hoo"] = meet.hoo
      meet["hUserid"] = @mHost.userid
      meet["hName"] = @mHost.name
      meet["hMembers"] = @mHost.members
      meet["hPicture"] = @mHost.picture

      @meet << meet
    end

    @meet
  end
  
  def self.manage_meet(params)
    if params[:mCode] == ""
      @meet = Meet.where(mHost: params[:mHost])
    else
  	  @meet = Meet.where(mCode: params[:mCode]).first
    end
  	
  	case params[:type]
  		when "participants"
        @person = []
        if params[:mCode] == ""
          @meet.each do |pmeet|
            @person.concat pmeet.participants
          end
        else
          @person.concat @meet.participants
        end
  			
  			@result = []
  			@person.each do |person|
  				person["uHost"] = User.info(person["mUserid"])

          if ! params[:keyword].nil?
            @nperson = person["uHost"]
            @result << person if @nperson["name"] =~ /#{params[:keyword]}/
          else
              @result << person
          end
  			end
        if params[:sort] == "asc"
          case params[:order]
            when "name"
              @result.sort { |a,b| a[:uHost][:name] <=> b[:uHost][:name] }
            when "sex"
              @result.sort { |a,b| a[:uHost][:sex] <=> b[:uHost][:sex] }
            when "age"
              @result.sort { |a,b| b[:uHost][:dob] <=> a[:uHost][:dob] }
            when "group"
              @result.sort { |a,b| a[:uHost][:job] <=> b[:uHost][:job] }
            when "local"
              @result.sort { |a,b| a[:uHost][:local] <=> b[:uHost][:local] }
            when "phone"
              @result.sort { |a,b| a[:uHost][:phone] <=> b[:uHost][:phone] }
            when "ticket"
            when "check"
              @result.sort { |a,b| a[:mCheck] <=> b[:mCheck] }
            else
              @result.sort { |a,b| a[:created_at] <=> b[:created_at] }
          end
        else
          case params[:order]
            when "name"
              @result.sort { |a,b| b[:uHost][:name] <=> a[:uHost][:name] }
            when "sex"
              @result.sort { |a,b| b[:uHost][:sex] <=> a[:uHost][:sex] }
            when "age"
              @result.sort { |a,b| a[:uHost][:dob] <=> b[:uHost][:dob] }
            when "group"
              @result.sort { |a,b| b[:uHost][:job] <=> a[:uHost][:job] }
            when "local"
              @result.sort { |a,b| b[:uHost][:local] <=> a[:uHost][:local] }
            when "phone"
              @result.sort { |a,b| b[:uHost][:phone] <=> a[:uHost][:phone] }
            when "ticket"
            when "check"
              @result.sort { |a,b| b[:mCheck] <=> a[:mCheck] }
            else
              @result.sort { |a,b| b[:created_at] <=> a[:created_at] }
          end
        end
      @person
  		when "waittings"
  			@person = @meet.watings
  			@result = []
  			@person.each do |person|
  				person["uHost"] = User.info(person[:mUserid])

				if ! params[:keyword].nil?
					@nperson = person["uHost"]
					@result << person if @nperson[:name] =~ /#{params[:keyword]}/
				else
  					@result << person
				end
  			end
  			if params[:sort] == "asc"
				case params[:order]
					when "name"
						@result.sort { |a,b| a[:uHost][:name] <=> b[:uHost][:name] }
					when "sex"
						@result.sort { |a,b| a[:uHost][:sex] <=> b[:uHost][:sex] }
					when "age"
						@result.sort { |a,b| b[:uHost][:dob] <=> a[:uHost][:dob] }
					when "group"
						@result.sort { |a,b| a[:uHost][:job] <=> b[:uHost][:job] }
					when "local"
						@result.sort { |a,b| a[:uHost][:local] <=> b[:uHost][:local] }
					when "phone"
						@result.sort { |a,b| a[:uHost][:phone] <=> b[:uHost][:phone] }
					when "ticket"
					when "check"
						@result.sort { |a,b| a[:mCheck] <=> b[:mCheck] }
					else
						@result.sort { |a,b| a[:created_at] <=> b[:created_at] }
				end
			else
				case params[:order]
					when "name"
						@result.sort { |a,b| b[:uHost][:name] <=> a[:uHost][:name] }
					when "sex"
						@result.sort { |a,b| b[:uHost][:sex] <=> a[:uHost][:sex] }
					when "age"
						@result.sort { |a,b| a[:uHost][:dob] <=> b[:uHost][:dob] }
					when "group"
						@result.sort { |a,b| b[:uHost][:job] <=> a[:uHost][:job] }
					when "local"
						@result.sort { |a,b| b[:uHost][:local] <=> a[:uHost][:local] }
					when "phone"
						@result.sort { |a,b| b[:uHost][:phone] <=> a[:uHost][:phone] }
					when "ticket"
					when "check"
						@result.sort { |a,b| b[:mCheck] <=> a[:mCheck] }
					else
						@result.sort { |a,b| b[:created_at] <=> a[:created_at] }
				end
			end
  		when "ticket"
  			@result = @meet.tickets
  		when "report"
  			@result = @meet.participants
  	end
  end
  
  def self.manage_count_meet(params)
  	if params[:mCode] == ""
      @meet = Meet.where(mHost: params[:mHost])
    else
  	  @meet = Meet.where(mCode: params[:mCode]).first
    end
  	@result = Hash.new
  	case params[:type]
  		when "person"
        if params[:mCode] == ""
          @result[:partice] = 0
          @result[:waitting] = 0
          @result[:checkup] = 0
          @result[:check] = 0
          @meet.each do |meet|
            @result[:partice] += (meet.participants.count) ? meet.participants.count : 0
            @result[:waitting] += (meet.watings.count) ? meet.watings.count : 0
            @result[:checkup] += (meet.checkup.count) ? meet.checkup.count : 0
          end
          if @result[:partice] > 0
              @result[:check] += ((@result[:checkup].to_f / @result[:partice].to_f) * 100).ceil
          end
        else
          @result[:partice] = (@meet.participants.count) ? @meet.participants.count : 0
          @result[:waitting] = (@meet.watings.count) ? @meet.watings.count : 0
          if @result[:partice] > 0
              @result[:check] = ((@meet.checkup.count.to_f / @meet.participants.count.to_f) * 100).ceil
          end
          @result[:check] ||= 0
        end
  		when "ticket"
  			@esales = TicketSold.where(:mCode => params[:mCode],:tState => 10)
        @total = 0
        @tax = 0
        @refund = 0
        @esales.each do |sale|
          sPrice = sale.tPrice * sale.tQuantity
          sTax = sale.tPrice * sale.tQuantity * 0
          hTax = sale.tPrice * sale.tQuantity * 0.025
          refund = sPrice - hTax
          @total += sPrice
          @tax += hTax
          @refund += refund
        end
        @result[:total] = number_with_delimiter(@total)
        @result[:sales] = number_with_delimiter(@tax)
        @result[:refund] = number_with_delimiter(number_with_precision(@refund, :precision => 0))
  		when "report"
			
  	end
  	@result
  end
  def self.dateSE(date_arr)
	date_arr = date_arr.split(",")
	ndate_arr = Array.new
	date_arr.each do |date|
		date.gsub!(/\s+/, "")
		if date!=""
			ndate_arr << Date.strptime(date, "%Y-%m-%d")
		end
	end 
	result = Array.new
	if ndate_arr.length <=1
		dates = ndate_arr[0]
		datee = ndate_arr[0]
	else
		dates =  ndate_arr[0]#Date.strptime(date_arr[0].gsub!(/\s+/, ""), "%Y-%m-%d")
		datee =  ndate_arr[1]#Date.strptime(date_arr[1].gsub!(/\s+/, ""), "%Y-%m-%d")
		if dates > datee
			tmp = dates
			dates = datee
			datee = tmp
		end
		if ndate_arr.length > 2
			ndate_arr.drop(2).each do |date|
				cmpdate = date
				if dates > cmpdate
					dates = cmpdate
				elsif datee < cmpdate
					datee = cmpdate
				end
			end
		end
	end
	result[0] = dates
	result[1] = datee
	return result
  end
  def partice_cnt
    #gPartice = Hoopartice.getPartice(self.mCode)
    #gPartice[:particecnt].to_i 
    TicketSold.saleTicket(:mCode => self.mCode).count
  end	
  def category_icon
	"<a href=\"/category/#{self.mCategory}\" class=\"category_icon\"></a>"
  end
  def hoo
    #gPartice = Hoopartice.getPartice(self.mCode)
    #gPartice[:particecnt].to_i 
    hCnt = Hoolike.hoocount(self.mCode)
  end
  def meetcmt
    Meetcmt.cmtcount(self.mCode)
  end
  def paytype
	@pay = Hash.new
	@pay[:card] = 0
	@pay[:phone] = 0

	self.mPaytype.split(',').each do |value|
		if value.strip == "card"
			@pay[:card] =1
		elsif value.strip == "801"
			@pay[:phone] =1
		end
	end
	return @pay
  end
  def hootalk
	Meetcmt.where(mCode: self.mCode).desc(:created_at)
  end
  def participants
	Hoopartice.where(mCode: self.mCode, mState: 1)
  end
  def watings
	Hoopartice.where(mCode: self.mCode, mState: 0)
  end
  def tickets
	Ticket.where(mCode: self.mCode)
  end
  def checkup
	Hoopartice.where(mCode: self.mCode, mCheck: 1)
  end
  def checkout
	Hoopartice.where(mCode: self.mCode, mCheck: 0)
  end
  def meet_date
	date = I18n.l(self.mDateS, :format => '%Y.%m.%d')
	if self.mDateS !=self.mDateE
	    #date = "#{date} ~ #{I18n.l(self.mDateE, :format => '%Y.%m.%d')}"
	end
	times = (self.mTimeS.to_i >= 12)?"PM #{(self.mTimeS.to_i-12)}:00 " : "AM #{self.mTimeS.to_i}:00"
	timee = (self.mTimeE.to_i >= 12)?"PM #{(self.mTimeE.to_i-12)}:00 " : "AM #{self.mTimeE.to_i}:00"
	"#{date}"
  end	
  def meet_time
	times = (self.mTimeS.to_i >= 12)?"PM #{(self.mTimeS.to_i-12)}:00 " : "AM #{self.mTimeS.to_i}:00"
	"#{times}"
  end	
  def meet_place
	"#{self.mAddress} #{self.mPlace}"
  end	
  def meet_price
	ticket = Ticket.where(mCode: self.mCode)
	minprice = ticket.min(:tPrice).to_i
	maxprice = ticket.max(:tPrice).to_i
	if minprice > 0
		if minprice == maxprice
			"#{number_to_currency(minprice, :locale => :ko)}" 
		else
			"#{number_to_currency(minprice, :locale => :ko)} ~ #{number_to_currency(maxprice, :locale => :ko)}" 			
		end
	else
		"무료"
	end
  end	
  def meet_people
	"#{self.partice_cnt} 장 구매"
  end
  def meet_group	
	Group.where(mCode: self.mCode).count
  end
  def card_date  
	date = I18n.l(self.mDateS, :format => '%m.%d')
	if self.mDateS !=self.mDateE
	    date = "#{date} ~ #{I18n.l(self.mDateE, :format => '%m.%d')}"
	end
  end	
  def end_date  
    date = self.mDate.split(",")
	if((date.size-2) > 0)
		date[(date.size-2)].gsub!(/\s+/, "")
	else
	    date[0]
	end
  end	
  def card_time
  timeTs = (self.mTimeS.to_i >= 12)?"PM " : "AM "
	timeTe = (self.mTimeE.to_i >= 12)?"PM " : "AM "
	times = (self.mTimeS.to_i >= 13)?"#{(self.mTimeS.to_i-12)}:00 " : "#{self.mTimeS.to_i}:00"
	timee = (self.mTimeE.to_i >= 13)?"#{(self.mTimeE.to_i-12)}:00 " : "#{self.mTimeE.to_i}:00"
	"#{timeTs}#{times}"
  end	 
  def card_address
    @card_address = self.mAddress.split(' ')
    "#{@card_address[0]} #{@card_address[1]}"
  end	 
  def card_place
	if self.mPlace.length > 8
		"#{self.mPlace[0..8]}..."
	else
		"#{self.mPlace}"
	end	
  end	

  def card_price
	ticket = Ticket.where(mCode: self.mCode)
	minprice = ticket.min(:tPrice).to_i
	if minprice > 0
		"#{number_to_currency(minprice, :locale => :ko)}" 
	else
		"무료"
	end
  end	
  def card_origin_price
	ticket = Ticket.where(mCode: self.mCode)
	minprice = ticket.min(:tOriginPrice).to_i
	if minprice > 0
		"#{number_to_currency(minprice, :locale => :ko)}" 
	else
		"무료"
	end
  end	
  def labelPaid
	if self.mPrice != 0 and self.mPrice != '0'
		"<img class=\"label_paid\" src=\"#{S3ADDR}hooful/card_paid.png\">"
	end
  end	
  def labelDday
	today = Date.today.strftime('%s')
    meetday = I18n.l(Date.strptime(self.mDate, "%Y-%m-%d"), :format => '%s')
	leftday = (meetday.to_i-today.to_i)/86400
	if leftday >= 1 and leftday <= 3
		"<div class=\"label_dday\">D-#{leftday}</div>"
	elsif leftday == 0
		"<div class=\"label_dday\">D-Day</div>"
	end
  end	
  def host
	User.info(self.mHost)
  end	
  def nHost
	User.where(:userid => self.mHost).last
  end	
  def typeSex
    TicketSold.chkTicketSex(self.mCode)
  end

  # inc/dec Count
  def self.incHoo(mCode)
    Meet.where(:mCode => mCode).last.inc(:uHoo, 1)
  end
  def self.popHoo(mCode)
    Meet.where(:mCode => mCode).last.inc(:uHoo, -1)
  end
  def self.incCmt(mCode)
    Meet.where(:mCode => mCode).last.inc(:uCmtcnt, 1)
  end
  def self.popCmt(mCode)
    Meet.where(:mCode => mCode).last.inc(:uCmtcnt, -1)
  end
  def self.incFemale(mCode)
    Meet.where(:mCode => mCode).last.inc(:uFemale, 1)
  end
  def self.popFemale(mCode)
    Meet.where(:mCode => mCode).last.inc(:uFemale, -1)
  end
  def self.incMale(mCode)
    Meet.where(:mCode => mCode).last.inc(:uMale, 1)
  end
  def self.popMale(mCode)
    Meet.where(:mCode => mCode).last.inc(:uMale, -1)
  end
end
