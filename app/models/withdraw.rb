class Withdraw
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :mUserid, type: String
  field :mBank, type: String
  field :mAccount, type: String
  field :mHolder, type: String
  field :mState, type: Integer
  field :mPrice, type: Integer
  field :mYear, type: String
  field :mMonth, type: String
  field :mDay, type: String

  def self.save(mBank, mHolder,mAccount,mUserid,mCode, mPrice)
    create! do |withdraw|		
      withdraw.mCode = mCode
      withdraw.mUserid = mUserid
      withdraw.mBank = mBank
      withdraw.mAccount = mAccount
      withdraw.mHolder = mHolder
      withdraw.mState = "0"
      withdraw.mPrice = mPrice
      withdraw.mYear = Time.now.strftime("%Y")
      withdraw.mMonth = Time.now.strftime("%m")
      withdraw.mDay = Time.now.strftime("%d")
    end
  end

  def self.index(params)
    @tdata = Withdraw.where(:mUserid => params[:mUserid]).desc(:created_at)
    @wdata = Array.new
    @tdata.each do |tdata|
      tdata[:create_date] = tdata[:created_at].to_time.strftime("%Y. %m. %d %H:%M")
      @wdata << tdata
    end
    @wdata
  end

  def self.getWithdraw(params)
    @with = Withdraw.where(:mYear => params[:mYear], :mMonth => params[:mMonth])
    @cal = @sum = []
    for n in 0..31
      @sum[n] = 0
    end
    @with.each do |with|
      @sum[with.mDay.to_i] += with.mPrice
    end
    @sum.each_with_index do |sum,i|
      @cal[i] = {price: "#{@sum[i]}"}
    end
    @cal
  end

  def self.getWithdrawDetail(params)
    wid = Withdraw.only(:_id).where(:mYear => params[:mDate].to_s.split('-')[0], :mMonth => params[:mDate].to_s.split('-')[1].to_i, :mDay => params[:mDate].to_s.split('-')[2]).map(&:_id)
    @esales = TicketSold.where(:tWid.in => wid)
    @esales
  end

  def self.strdate
    self.created_at.strftime("%Y. %m. %d %H:%M")
  end
end
