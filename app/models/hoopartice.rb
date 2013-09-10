#encoding: utf-8
class Hoopartice
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :mHost, type: String
  field :mUserid, type: String
  field :mDate, type: String
  field :mState, type: String
  field :mCheck, type: String
  field :mPaid, type: String
  field :mWithdraw, type: String
  field :mTickets, type: Array
  field :mTid, type: String
  validates_uniqueness_of :mUserid, :scope => :mCode
  embeds_many  :tickets
  has_many  :payhistory, autosave: true
  
  def userinfo
	Member.info(self.mUserid)
  end

  def self.checkUp(params)
    @member = Hoopartice.where(:mUserid => params[:userid],:mCode =>  params[:mCode]).last
    @member[:mCheck] = "1"
    
    if @member.save
      @member
    else
      {:result => "faild"}
    end
  end

  def self.checkDown(params)
    @member = Hoopartice.where(:mUserid => params[:userid],:mCode =>  params[:mCode]).last
    @member[:mCheck] = "0"
    
    if @member.save
      @member
    else
      {:result => "faild"}
    end
  end

  def self.stateUp(params)
	@member = Hoopartice.where(:mUserid => params[:userid],:mCode =>  params[:mCode]).last
	@member[:mState] = "1"
	@member[:mCheck] = "0"
	
	if @member.save
	  @member
	else
	  {:result => "faild"}
	end
  end

  def self.stateDown(params)
	@member = Hoopartice.where(:mUserid => params[:userid],:mCode =>  params[:mCode]).last
	@member[:mState] = "0"
	@member[:mCheck] = "0"
	
	if @member.save
	  @member
	else
	  {:result => "faild"}
	end
  end

  def self.getPartice(mCode)
    verify_user = Hoopartice.where(mCode: mCode)
  
    @pstatus = verify_user.first
  	@partice = Hash.new
		@partice[:status] = (verify_user.length != 0) ? 1 : 0

  	if ! @pstatus
  		@pstatus = Hash.new
  		@pstatus[:mState] = false
  	end
  	@partice[:mState] = @pstatus[:mState] ? @pstatus[:mState] : "0"
    @partice[:mCheck] = @pstatus[:mCheck] ? @pstatus[:mCheck] : "0"
    #@partice[:particecnt] = Hoopartice.where(mCode: mCode).count
    @partice[:particecnt] = Hoopartice.where('$and' => [{"mCode" => mCode},{"mState" => "1"}]).count
  	return @partice
  end

  # 2. 판매현황
  def self.saleTicket(mParam)
    @esales = Hoopartice.where(:mCode => mParam[:mCode],:mState => 1)
    @sales = []
    @esales.each do |sale|
      sale["uHost"] = User.info(sale[:mUserid])
      sPrice = sTax = hTax = 0

      sale.mTickets.each do |ticket|
        sPrice = ticket["tPrice"] if ticket["tPrice"]
        sTax = ticket["tPrice"] * 0 if ticket["tPrice"]
        hTax = ticket["tPrice"] * 0.025 if ticket["tPrice"]
      
        sale["saleTicket"] = ticket["tName"]
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
    end
    @sales
  end
  
end
