#encoding: UTF-8
class TicketSold
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :mUserid, type: String
  field :tId, type: String
  field :payId, type: String
  field :orderId, type: String
  field :tCode, type: String
  field :tName, type: String
  field :tQuantity, type: Integer
  field :tPrice, type: Integer
  field :oPrice, type: Integer
  field :tDescription, type: String
  field :tDesignated, type: Integer
  field :tState, type: Integer
  field :tUse, type: Integer
  field :tUseDate, type: String
  field :tUseTime, type: String
  field :tReserveDate, type: String
  field :tReserveTime, type: String
  field :tReserveDateEx, type: String
  field :tReserveTimeEx, type: String
  field :tReserveText, type: String
  field :tAcceptDate, type: String
  field :tAcceptTime, type: String
  field :tWid, type: String
  field :tWdate, type: String
  field :tWtime, type: String
  field :tEvent, type: Integer
  index({ mCode: 1 }, { unique: false})

  validates_uniqueness_of :tCode
  validates_presence_of :tName, :message => "is empty"
  validates_numericality_of :tQuantity,only_integer: true, greater_than: 0
  validates_numericality_of :tPrice,only_integer: true, greater_than_or_equal_to: 0

  def self.create_ticket(params)
    ticket_all= Array.new
    valid = true
    errormsg = ""
    @ticket_info=params[:ticketInfo].split('/,/')
    @ticket_info.each do |tinfo|
      info=tinfo.split('/+/')	#0: id, 1: name, 2: price, 3: quantity  , 4: description  , 5: oprice	
      info[2] = info[2].to_i
      info[3]	= info[3].to_i
      
	  for ti in 1..info[3]
        ticket = TicketSold.new
        begin
          codeGenerate =  [(0..9),('A'..'Z')].map{|i| i.to_a}.flatten
          tCode  =  (0...11).map{ codeGenerate[rand(codeGenerate.length)] }.join
          ticket.tCode			= tCode
          ticket.tName			= info[1]
          ticket.tPrice			= info[2]
          ticket.oPrice			= info[5]
          ticket.tQuantity		= 1
        end while !ticket.valid? 

        ticket.mCode			= params[:mCode]
        ticket.mUserid			= params[:mUserid]
        ticket.tId			= info[0]
        ticket.payId			= params[:tid]
        ticket.orderId			= Time.now.strftime("%Y%m%d") + "-" + params[:tid].to_s.split('.')[1]
        ticket.tDescription	= info[4]
        ticket.tDesignated	= info[5]
        ticket.tReserveDate = params[:mDate]
        ticket.tReserveTime = params[:mTimeS]
        ticket.tState	= (params[:mParticeCheck] == "false") ? 2 : 5
        ticket.tUse	= 0
        ticket.tUseDate	= ""
        ticket.tWid	= ""
        ticket.tWdate	= ""
        ticket.tWtime	= ""
        ticket.tEvent	= 0
        if ticket.valid?
          ticket_all << ticket  
        else
          valid = false
          returnmsg = ""
          ticket.errors.full_messages.each do |msg|
            returnmsg += msg+"\n"
          end
          errormsg += returnmsg
        end		
			
	  end if info[3]!=0

      if valid
          ticket_all.each(&:save)
          @userinfo = User.info(params[:mUserid])
          if @userinfo.sex.to_i == 1
            Meet.incMale(params[:mCode])
          else
            Meet.incFemale(params[:mCode])
          end
          GroupTalk.sendTalk("enter","", @userinfo,params[:mUserid],1)
      else
        errormsg
      end
    end
  end

  def self.refundTicket(tcode, state)
    TicketSold.where(:tCode => tcode).update_all(:tState => state)
  end


  def self.checkUp(params)
    @member = TicketSold.where(:tCode =>  params[:tCode]).last
    @member[:tUse] = "1"
    @member[:tUseDate] = Time.now.strftime("%Y. %m. %d %H:%M:%S")
    
    if @member.save
      @member
    else
      {:result => "faild"}
    end
  end

  def self.checkDown(params)
    @member = TicketSold.where(:tCode =>  params[:tCode]).last
    @member[:tUse] = "0"
    @member[:tUseDate] = ""
    
    if @member.save
      @member
    else
      {:result => "faild"}
    end
  end

  # 1. 판매현황
  def self.saleTicket(mParam)
    if mParam[:mCode] == ""
      host_code = Meet.only(:mCode).where(:mHost => mParam[:mHost]).map(&:mCode)
      @esales = TicketSold.where(:mCode.in => host_code,:tState.in => [1,2,3,4,5,10])
    else
      @esales = TicketSold.where(:mCode => mParam[:mCode],:tState.in => [1,2,3,4,5,10])
    end
    @sales = []
    @esales.each do |sale|
      sale["uHost"] = User.info(sale[:mUserid])
      sale["uMeet"] = Meet.load(sale[:mCode])
      sPrice = sTax = hTax = 0

      sPrice = sale["tPrice"]*sale["tQuantity"] if sale["tPrice"]
      sTax = sale["tPrice"]*sale["tQuantity"] * 0 if sale["tPrice"]
      hTax = sale["tPrice"]*sale["tQuantity"] * 0.025 if sale["tPrice"]
    
      sale["saleTicket"] = sale["tName"]
      sale["sPrice"] = sPrice
      sale["sTax"] = sTax
      sale["hTax"] = hTax
      sale["fPrice"] = sPrice - hTax

      if ! mParam[:keyword].nil?
        @nperson = sale["uHost"]
        @sales << sale if @nperson[:name] =~ /#{mParam[:keyword]}/
      else
        @sales << sale
      end
    end
    @sales
  end
  # 1-1. 상태별 판매현황
  def self.saleTicketState(mParam)
    if mParam[:mCode] == ""
      host_code = Meet.only(:mCode).where(:mHost => mParam[:mHost]).map(&:mCode)
      if mParam[:mList] == "all"
        @esales = TicketSold.where(:mCode.in => host_code)
      elsif mParam[:mState] == "0"
        @esales = TicketSold.where(:mCode.in => host_code,:tState.in => [2,3,4,5,10])
      else
        @esales = TicketSold.where(:mCode.in => host_code,:tState => mParam[:mState])
      end
    else
      if mParam[:mList] == "all"
        @esales = TicketSold.where(:mCode => mParam[:mCode])
      elsif mParam[:mState] == "0"
        @esales = TicketSold.where(:mCode.in => host_code,:tState.in => [2,3,4,5,10])
      else
        @esales = TicketSold.where(:mCode => mParam[:mCode],:tState => mParam[:mState])
      end
    end
    @sales = []
    @esales.each do |sale|
      sale["uHost"] = User.info(sale[:mUserid])
      sale["uMeet"] = Meet.load(sale[:mCode])
      sale["uMeet"]["sDateE"] = sale["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      sale["uMeet"]["sTimeE"] = sale["uMeet"]["mDateE"].strftime("%H:%M:%S")
      sale["uMeet"]["sYear"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
      sale["uMeet"]["sMonth"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
      sale["uMeet"]["sDay"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]
      sPrice = sTax = hTax = 0

      sPrice = sale["tPrice"]*sale["tQuantity"] if sale["tPrice"]
      sTax = sale["tPrice"]*sale["tQuantity"] * 0 if sale["tPrice"]
      hTax = sale["tPrice"]*sale["tQuantity"] * 0.025 if sale["tPrice"]
    
      sale["saleTicket"] = sale["tName"]
      sale["sPrice"] = sPrice
      sale["sTax"] = sTax
      sale["hTax"] = hTax
      sale["fPrice"] = sPrice - hTax

      if ! mParam[:keyword].nil?
        @nperson = sale["uHost"]
        @sales << sale if @nperson[:name] =~ /#{mParam[:keyword]}/
      else
        @sales << sale
      end
    end
    @sales
  end
  def self.saleTicketStateCount(mParam)
    if mParam[:mCode] == ""
      host_code = Meet.only(:mCode).where(:mHost => mParam[:mHost]).map(&:mCode)
      @esales = TicketSold.where(:mCode.in => host_code)
    else
      @esales = TicketSold.where(:mCode => mParam[:mCode])
    end

    @cntnum = Hash.new
    @cntnum[:snum] = 0
    @cntnum[:snum2] = 0
    @cntnum[:snum3] = 0
    @cntnum[:snum4] = 0
    @cntnum[:snum5] = 0
    @cntnum[:snum10] = 0
    @sales = []
    @esales.each do |sale|
      case sale[:tState]
        when 2
          @cntnum[:snum] += 1
          @cntnum[:snum2] += 1
        when 3
          @cntnum[:snum] += 1
          @cntnum[:snum3] += 1
        when 4
          @cntnum[:snum] += 1
          @cntnum[:snum4] += 1
        when 5
          @cntnum[:snum] += 1
          @cntnum[:snum5] += 1
        when 10
          @cntnum[:snum] += 1
          @cntnum[:snum10] += 1
      end
    end
    @cntnum
  end
  # 1-2. 사용된 판매현황
  def self.withdrawTicket(mParam)
    if mParam[:mCode] == ""
      host_code = Meet.only(:mCode).where(:mHost => mParam[:mHost]).map(&:mCode)
      @esales = TicketSold.where(:mCode.in => host_code,:tState => 10)
    else
      @esales = TicketSold.where(:mCode => mParam[:mCode],:tState => 10)
    end
    @sales = []
    @esales.each do |sale|
      sale["uHost"] = User.info(sale[:mUserid])
      sale["uMeet"] = Meet.load(sale[:mCode])
      sPrice = sTax = hTax = 0

      sPrice = sale["tPrice"]*sale["tQuantity"] if sale["tPrice"]
      sTax = sale["tPrice"]*sale["tQuantity"] * 0 if sale["tPrice"]
      hTax = sale["tPrice"]*sale["tQuantity"] * 0.025 if sale["tPrice"]
    
      sale["saleTicket"] = sale["tName"]
      sale["sPrice"] = sPrice
      sale["sTax"] = sTax
      sale["hTax"] = hTax
      sale["fPrice"] = sPrice - hTax

      if ! mParam[:keyword].nil?
        @nperson = sale["uHost"]
        @sales << sale if @nperson[:name] =~ /#{mParam[:keyword]}/
      else
        @sales << sale
      end
    end
    @sales
  end
  # 1-3. 출금신청 업데이트
  def self.withdrawCalcurate(mParam)
    if mParam[:mcode] == ""
      host_code = Meet.only(:mCode).where(:mHost => mParam[:mhost]).map(&:mCode)
      @esales = TicketSold.where(:mCode.in => host_code,:tState => 10)
    else
      @esales = TicketSold.where(:mCode => mParam[:mcode],:tState => 10)
    end
    @state = false

    if @esales.length > 1
      @esales.each do |sale|
        sale.tWid = mParam["wid"]
        sale.tWdate = Time.now.strftime("%Y. %m. %d")
        sale.tWtime = Time.now.strftime("%H:%M:%S")
        if sale.save!
          @state = true
        end
      end
    else
      esalestmp = @esales.first
      esalestmp.tState = 8
      esalestmp.tWid = mParam["wid"]
      esalestmp.tWdate = Time.now.strftime("%Y. %m. %d")
      esalestmp.tWtime = Time.now.strftime("%H:%M:%S")
      if esalestmp.save!
        @state = true
      end
    end
    esalestmp
  end

  # 2. 티켓리스트 - 사용자
  def self.listTicket(userid)
    @esales = TicketSold.where(:mUserid => userid,:tState.lt => 5)
    @sales = []
    @esales.each do |sale|
      if sale[:mCode]
      sale["uHost"] = User.info(sale[:mUserid])
      sale["uMeet"] = Meet.load(sale[:mCode])
      sale["uMeet"]["sDateE"] = sale["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      sale["uMeet"]["sTimeE"] = sale["uMeet"]["mDateE"].strftime("%H:%M:%S")
      sale["uMeet"]["sYear"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
      sale["uMeet"]["sMonth"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
      sale["uMeet"]["sDay"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]
      sPrice = sTax = hTax = 0

      sPrice = sale["tPrice"]*sale["tQuantity"] if sale["tPrice"]
      sTax = sale["tPrice"]*sale["tQuantity"] * 0 if sale["tPrice"]
      hTax = sale["tPrice"]*sale["tQuantity"] * 0.025 if sale["tPrice"]
    
      sale["saleTicket"] = sale["tName"]
      sale["sPrice"] = sPrice
      sale["sTax"] = sTax
      sale["hTax"] = hTax
      sale["fPrice"] = sPrice - hTax

     @sales << sale
     end
    end
    @sales
  end

  def self.ticketCount(userid)
    ticket = Hash.new
    ticket[:unuse] = TicketSold.where(:mUserid => userid,:tState => 1).count
    ticket[:reserved] = TicketSold.where(:mUserid => userid,:tState.gte => 2, :tState.lte => 5).count
    ticket[:used] = TicketSold.where(:mUserid => userid,:tState => 10).count
    ticket
  end

  def self.listGroupMeet(userid)
    @esales = TicketSold.where(:mUserid => userid,:tState => 1).desc(:_id).group_by {|d| d.mCode }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["mTitle"] = ticket["uMeet"]["mTitle"]
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["mCode"] = sale[1][0][:mCode]
      ticket["mUserid"] = sale[1][0][:mUserid]

     @sales << ticket
   end
   @sales
  end
  def self.listGroupTicket(userid, mcode)
    @esales = TicketSold.where(:mUserid => userid,:mCode => mcode ,:tState.lt => 5).desc(:_id).group_by {|d| d.tId }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["tId"] = sale[1][0][:tId]
      ticket["orderId"] = sale[1][0][:orderId]
      ticket["tCount"] = sale[1].count
      ticket["tId"] = sale[1][0][:tId]
      ticket["limit"] = ticket["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      ticket["sales"] = sale[1]

     @sales << ticket
   end
   @sales
  end
  def self.listGroupTicketAll(userid, orderId)
    @esales = TicketSold.where(:mUserid => userid,:orderId => orderId).desc(:_id).group_by {|d| d.tId }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["tId"] = sale[1][0][:tId]
      ticket["orderId"] = sale[1][0][:orderId]
      ticket["tState"] = sale[1][0][:tState]
      ticket["tCount"] = sale[1].count
      ticket["tId"] = sale[1][0][:tId]
      ticket["limit"] = ticket["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      ticket["sales"] = sale[1]

     @sales << ticket
   end
   @sales
  end

  def self.ticketmap
	  map = %Q{
		function() {
      var feed, friend;
      feed = 0;
      friend = 0;
      emit({tid: this.tId}, 1);
	  }
    }
	  reduce = %Q{
		function(key, values) {
		 var result = 0;
		  values.forEach(function(value) {
			result += value;
		  });	
		  return result;
		}
	  }
	 
	  TicketSold.collection.map_reduce(map, reduce, {:out => {:inline => 1}, :raw => true})["results"]
  end

  # 2-2. 티켓 예약리스트 - 사용자
  def self.reservedListTicket(userid)
    @esales = TicketSold.where(:mUserid => userid,:tState.gte => 2, :tState.lte => 5)
    @sales = []
    @esales.each do |sale|
      sale["uHost"] = User.info(sale[:mUserid])
      sale["uMeet"] = Meet.load(sale[:mCode])
      sale["uMeet"]["sDateE"] = sale["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      sale["uMeet"]["sTimeE"] = sale["uMeet"]["mDateE"].strftime("%H:%M:%S")
      sale["uMeet"]["sYear"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
      sale["uMeet"]["sMonth"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
      sale["uMeet"]["sDay"] = sale["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]
      sPrice = sTax = hTax = 0

      sPrice = sale["tPrice"]*sale["tQuantity"] if sale["tPrice"]
      sTax = sale["tPrice"]*sale["tQuantity"] * 0 if sale["tPrice"]
      hTax = sale["tPrice"]*sale["tQuantity"] * 0.025 if sale["tPrice"]
    
      sale["saleTicket"] = sale["tName"]
      sale["sPrice"] = sPrice
      sale["sTax"] = sTax
      sale["hTax"] = hTax
      sale["fPrice"] = sPrice - hTax

     @sales << sale
    end
    @sales
  end

  # 2-3. 티켓 구매리스트 - 사용자
  def self.orderListTicket(userid)
    @esales = TicketSold.all.where(:mUserid => userid).desc(:_id).group_by {|d| d.payId }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["tCode"] = sale[1][0][:tCode]
      ticket["mCode"] = sale[1][0][:mCode]
      ticket["mUserid"] = sale[1][0][:mUserid]
      ticket["tState"] = sale[1][0][:tState]
      ticket["uHost"] = User.info(sale[1][0][:mUserid])
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["count"] = sale[1].count
      ticket["sales"] = sale[1]
      ticket["tId"] = sale[1][0][:tId]
      ticket["tEvent"] = sale[1][0][:tEvent]
      ticket["orderId"] = sale[1][0][:orderId]
      ticket["created_at"] = sale[1][0][:created_at].strftime("%Y-%m-%d")
      ticket["payinfo"] = Payhistory.loadPay(sale[1][0][:payId])

     @sales << ticket
    end
    @sales
  end

  def self.orderDetailTicket(userid, orderid)
    @esales = TicketSold.all.where(:mUserid => userid, :orderId => orderid)
  end

  def self.choiceTicket(userid, mcode)
    @esales = TicketSold.all.where(:mUserid => userid, :mCode => mcode).or(:tState.in => [1,2,3]).group_by {|d| d.tId }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["_id"] = sale[1][0][:_id]
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["tCode"] = sale[1][0][:tCode]
      ticket["mCode"] = sale[1][0][:mCode]
      ticket["tState"] = sale[1][0][:tState]
      ticket["uHost"] = User.info(sale[1][0][:mUserid])
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["count"] = sale[1].count
      ticket["tId"] = sale[1][0][:tId]
      ticket["orderId"] = sale[1][0][:orderId]
      ticket["uMeet"]["sDateE"] = ticket["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      ticket["uMeet"]["sTimeE"] = ticket["uMeet"]["mDateE"].strftime("%H:%M:%S")
      ticket["uMeet"]["sYear"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
      ticket["uMeet"]["sMonth"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
      ticket["uMeet"]["sDay"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]

     @sales << ticket
    end
    @sales
  end

  def self.oldlistTicket(userid)
    @esales = TicketSold.where(:mUserid => userid,:tState => 10).desc(:_id).group_by {|d| d.mCode }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["uHost"] = User.info(sale[1][0][:mUserid])
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["mTitle"] = ticket["uMeet"]["mTitle"]
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["mCode"] = sale[1][0][:mCode]
      ticket["mUserid"] = sale[1][0][:mUserid]
      ticket["count"] = sale[1].count
      ticket["sales"] = sale[1]
      ticket["tId"] = sale[1][0][:tId]
      ticket["orderId"] = sale[1][0][:orderId]
      ticket["created_at"] = sale[1][0][:created_at].strftime("%Y-%m-%d")
      ticket["payinfo"] = Payhistory.loadPay(sale[1][0][:payId])
      ticket["uMeet"]["sDateE"] = ticket["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      ticket["uMeet"]["sTimeE"] = ticket["uMeet"]["mDateE"].strftime("%H:%M:%S")
      ticket["uMeet"]["sYear"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
      ticket["uMeet"]["sMonth"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
      ticket["uMeet"]["sDay"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]

     @sales << ticket
   end
   @sales
  end

  # 3. 티켓정보 - 사용자
  def self.odetailTicket(tid)
    @esales = TicketSold.where(:orderId => tid,:tState.gte => 1).desc(:_id).group_by {|d| d.mCode }
    @sales = []
    @esales.each do |sale|
      ticket = Hash.new
      ticket["uMeet"] = Meet.load(sale[1][0][:mCode])
      ticket["mTitle"] = ticket["uMeet"]["mTitle"]
      ticket["_id"] = sale[1][0][:_id]
      ticket["tId"] = sale[1][0][:tId]
      ticket["tCode"] = sale[1][0][:tCode]
      ticket["tName"] = sale[1][0][:tName]
      ticket["tDescription"] = sale[1][0][:tDescription]
      ticket["mCode"] = sale[1][0][:mCode]
      ticket["mUserid"] = sale[1][0][:mUserid]
      ticket["tState"] = sale[1][0][:tState]
      ticket["payId"] = sale[1][0][:payId]
      ticket["created_at"] = sale[1][0][:created_at]
      ticket["tState"] = sale[1][0][:tState]
      ticket["uMeet"]["sDateE"] = ticket["uMeet"]["mDateE"].strftime("%Y-%m-%d")
      ticket["uMeet"]["sTimeE"] = ticket["uMeet"]["mDateE"].strftime("%H:%M:%S")
      ticket["uMeet"]["sYear"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
      ticket["uMeet"]["sMonth"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
      ticket["uMeet"]["sDay"] = ticket["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]

     @sales << ticket
   end
    @sales
  end
  def self.detailTicket(tid)
    @sales = TicketSold.where(:_id => tid,:tState.gte => 1).last
    @sales["uHost"] = User.info(@sales[:mUserid])
    @sales["uMeet"] = Meet.load(@sales[:mCode])
    @sales["uMeet"]["sDateE"] = @sales["uMeet"]["mDateE"].strftime("%Y-%m-%d")
    @sales["uMeet"]["sTimeE"] = @sales["uMeet"]["mDateE"].strftime("%H:%M:%S")
    @sales["uMeet"]["sYear"] = @sales["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
    @sales["uMeet"]["sMonth"] = @sales["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
    @sales["uMeet"]["sDay"] = @sales["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]
    sPrice = sTax = hTax = 0

    sPrice = @sales["tPrice"]*@sales["tQuantity"] if @sales["tPrice"]
    sTax = @sales["tPrice"]*@sales["tQuantity"] * 0 if @sales["tPrice"]
    hTax = @sales["tPrice"]*@sales["tQuantity"] * 0.025 if @sales["tPrice"]
  
    @sales["saleTicket"] = @sales["tName"]
    @sales["sPrice"] = sPrice
    @sales["sTax"] = sTax
    @sales["hTax"] = hTax
    @sales["fPrice"] = sPrice - hTax
    @sales
  end

  def self.detailTicketCode(tid)
    @sales = TicketSold.where(:tCode => tid,:tState.gte => 1).last
    @sales["uHost"] = User.info(@sales[:mUserid])
    @sales["uMeet"] = Meet.load(@sales[:mCode])
    @sales["uMeet"]["sDateE"] = @sales["uMeet"]["mDateE"].strftime("%Y-%m-%d")
    @sales["uMeet"]["sTimeE"] = @sales["uMeet"]["mDateE"].strftime("%H:%M:%S")
    @sales["uMeet"]["sYear"] = @sales["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[0]
    @sales["uMeet"]["sMonth"] = @sales["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[1]
    @sales["uMeet"]["sDay"] = @sales["uMeet"]["sDateE"].to_s.split(',')[0].split('-')[2]
    sPrice = sTax = hTax = 0

    sPrice = @sales["tPrice"]*@sales["tQuantity"] if @sales["tPrice"]
    sTax = @sales["tPrice"]*@sales["tQuantity"] * 0 if @sales["tPrice"]
    hTax = @sales["tPrice"]*@sales["tQuantity"] * 0.025 if @sales["tPrice"]
  
    @sales["saleTicket"] = @sales["tName"]
    @sales["sPrice"] = sPrice
    @sales["sTax"] = sTax
    @sales["hTax"] = hTax
    @sales["fPrice"] = sPrice - hTax
    @sales
  end

  # 4. 코드로 티켓검색
  def self.searchCode(mParam)
    if mParam[:mCode] == ""
      host_code = Meet.only(:mCode).where(:mHost => mParam[:mHost]).map(&:mCode)
      @esales = TicketSold.where(:mCode.in => host_code,:tCode => mParam[:mcCode],:tState.gte => 5)
    else
      @esales = TicketSold.where(:mCode => mParam[:mCode],:tCode => mParam[:mcCode],:tState.gte => 5)
    end
    @sales = []
    @esales.each do |ticket|
      ticket["tReserveDate"] = ticket[:tReserveDate].split(",")[0] if ticket[:tReserveDate]
      ticket["uHost"] = User.info(ticket[:mUserid])
      ticket["uMeet"] = Meet.load(ticket[:mCode])
      @sales << ticket
    end
    @sales
  end

  # 5. 코드로 티켓상태 변경
  def self.useCode(mParam)
    if mParam[:state] == "1"
      @ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tUse => 0, :tState => 5)
    else
      @ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tUse => 1, :tState => 10, :tUseDate => Time.now.strftime("%Y. %m. %d"), :tUseTime => Time.now.strftime("%H:%M:%S"))
    end
    TicketSold.where(:tCode => mParam[:tCode])
  end
  # 5-1. 코드로 티켓상태 변경
  def self.changeState(mParam)
    if mParam[:tState].to_i == 10
      @ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tState => mParam[:tState].to_i, :tUseDate => Time.now.strftime("%Y. %m. %d"), :tUseTime => Time.now.strftime("%H:%M:%S"))
    elsif mParam[:tState].to_i == 5
      @ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tState => mParam[:tState].to_i, :tAcceptDate => Time.now.strftime("%Y. %m. %d"), :tAcceptTime => Time.now.strftime("%H:%M:%S"))
      
      #문자발송 - 예약신청(2) > 예약확정(5)
      @tinfo = TicketSold.where(:tCode => mParam[:tCode]).first
      sParam = Hash.new
	  sParam[:userid] = @tinfo.mUserid
	  sParam[:mCode] = @tinfo.mCode
	  sParam[:ticket] = @tinfo.tName +  @tinfo.tDescription
	  sParam[:date] = @tinfo.tReserveDate
	  @grouplist = Group.where(:mCode => sParam[:mCode])
	  @groupcheck = false
	  @groupcheck = GroupMember.where(:mUserid => sParam[:userid],:group_id.in => @grouplist.map(&:_id)).exists? if @grouplist
	  if @groupcheck == true
	  	Smshistory.send("reserv_complete_ingroup",sParam)        
		Notification.send("reserved_complete_group", sParam[:userid],sParam[:mCode], "#{sParam[:ticket]}/,/#{sParam[:date]}")
		
	  else
	  	Smshistory.send("reserv_complete",sParam)          
		Notification.send("reserved_complete_nogroup", sParam[:userid],sParam[:mCode], "#{sParam[:ticket]}/,/#{sParam[:date]}")

	  end
	  
    else
      @ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tState => mParam[:tState].to_i)
      
      #문자발송 - 예약신청(2) > 예약불가(3)
      @tinfo = TicketSold.where(:tCode => mParam[:tCode]).first
      sParam = Hash.new
	  sParam[:userid] = @tinfo.mUserid
	  sParam[:mCode] = @tinfo.mCode
	  sParam[:ticket] = @tinfo.tName +  @tinfo.tDescription
	  sParam[:date] = @tinfo.tReserveDate
	  Smshistory.send("reserv_cancel",sParam)          
	  Notification.send("reserved_unable", sParam[:userid],sParam[:mCode], "#{sParam[:ticket]}/,/#{sParam[:date]}")

    end
    TicketSold.where(:tCode => mParam[:tCode])
  end

  def self.changeOnlyState(tCode, tState, tUse)
    @ticket = TicketSold.where(:tCode => tCode).update(:tUse => tUse, :tState => tState)
    if tState.to_i == 1
      TicketSold.where(:tCode => tCode).update(:tReserveDate => '', :tReserveText => '', :tReserveTime => '')
    end
  end

  #6. 구매한 티켓수량 확인
  def self.chkCountTicketsold(mParam)
    @ticket = TicketSold.where(:tState => 1, :mCode => mParam[:mCode], :mUserid => mParam[:mUserid]).count
  end

  # 7. 코드로 티켓예약
  def self.reservCode(mParam)
    if mParam[:state] == "1"
      @esales = TicketSold.all.where(:mUserid => mParam[:mHost], :mCode => mParam[:mCode]).or(:tState.in => [nil,1,3]).group_by {|d| d.tId }
      @esales.each do |sale|
        @eticket = sale[1]
      end
      @tsales = []
      @nCnt = 0
      @eticket.each do |sale|
        break if @nCnt == mParam[:count].to_i
        @tsales << sale
        @nCnt += 1
        
        if mParam[:tState] == "3"
          @ticket = TicketSold.where(:tCode => sale[:tCode]).update(:tState => 4, :tReserveDate => mParam[:tUseDate],:tReserveTime => mParam[:tUseTime], :tReserveDateEx => sale[:tReserveDate],:tReserveTimeEx => sale[:tReserveTime],:tReserveText => mParam[:tReserveText])
          
		  #예약
        else
          @ticket = TicketSold.where(:tCode => sale[:tCode]).update(:tState => 2, :tReserveDate => mParam[:tUseDate],:tReserveTime => mParam[:tUseTime],:tReserveText => mParam[:tReserveText])
		  #취소
        end
      end
      
      #@ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tState => 2, :tReserveDate => mParam[:tUseDate],:tReserveTime => mParam[:tUseTime],:tReserveText => mParam[:tReserveText])
    #else
      #@ticket = TicketSold.where(:tCode => mParam[:tCode]).update(:tState => 1, :tReserveDate => '',:tReserveTime => '')
    end

    @sales = TicketSold.where(:tCode => @tsales.first[:tCode]).last

	# 문자발송 - 구매완료(1) > 예약신청(2)
	# 문자발송 - 예약불가(3) > 예약신청(2)
	sParam = Hash.new
	sParam[:userid] = mParam[:mHost]
	sParam[:host] = Meet.load(mParam[:mCode]).mHost
	sParam[:mCode] = mParam[:mCode]
	sParam[:ticket] = @sales[:tName] +  @sales[:tDescription]
	sParam[:date] = mParam[:tUseDate]
	Smshistory.send("reserv",sParam)
	Notification.send("reserved_request", sParam[:userid], sParam[:host], "#{mParam[:mCode]}/,/#{sParam[:ticket]}/,/#{mParam[:tUseDate]}")


    @sales["meet_date"] = @sales[:tUseDate].to_s.split(",")[0]
    @tmpTime = (@sales[:tReserveTime].to_f%1 == 0)?"00":"30"
    @time1 = (@sales[:tReserveTime].to_i >= 12)?"PM. " : "AM. "
    @time2 = (@sales[:tReserveTime].to_i > 12)?"#{(@sales[:tUseTime].to_i.ceil-12)}" : "#{@sales[:tUseTime].to_i.ceil}"
    @sales["meet_time"] = "#{@time1}#{@time2}:#{@tmpTime}"
    @sales["uHost"] = User.info(@sales[:mUserid])
    @sales["uMeet"] = Meet.load(@sales[:mCode])
      
    return @sales
  end

  def self.cancelTicket(orderId, tId)
		uri = URI.parse('https://service.paygate.net/payment/pgtlCancel.jsp?pmemberid=ndysjo&pmemberpasshash=Hooful@payment1307&transactionid=' + tId)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
    @data = http.get(uri.request_uri)
    @data = @data.body.to_s.gsub!(/\n/,"")
    @refund = {}
    @data.split("&").each do |d|
      k,v = d.split('=')
      @refund[k] = v.to_s
    end
    @refund["orderId"] = orderId
    @refund["tId"] = tId
    #Payhistory.create_refund_history(@refund)
    if @refund["ReplyCode"].to_s == "0000"
      TicketSold.where(:payId => tId).update_all(:tState => 7)
      @esales = TicketSold.where(:payId => tId)
      if @esales.count > 1
        @esales.each do |sale|
          @userinfo = User.info(sale[:mUserid])
          if @userinfo.sex.to_i == 1
            Meet.popMale(sale[:mCode])
          else
            Meet.popFemale(sale[:mCode])
          end
          GroupTalk.sendTalk("leave","", @userinfo,sale[:mUserid],1)
        end
      else
        @userinfo = User.info(@esales.last[:mUserid])
        if @userinfo.sex.to_i == 1
          Meet.popMale(@esales.last[:mCode])
        else
          Meet.popFemale(@esales.last[:mCode])
        end
        GroupTalk.sendTalk("leave","", @userinfo,@esales.last[:mUserid],1)
      end
    end    
    @refund
  end

  # 구매자 남녀구분
  def self.chkTicketSex(mCode)
    @esales = TicketSold.where(:mCode => mCode,:tState.in => [1,2,3,4,5,10])
    @sales = Hash.new
    @sales[:male] = 0
    @sales[:female] = 0
    @esales.each do |sale|
      user = User.info(sale[:mUserid])
      if user[:sex].to_i == 1      
        @sales[:male] += 1
      else
        @sales[:female] += 1
      end
    end
    @sales
  end

end