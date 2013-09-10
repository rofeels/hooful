class Hoolike
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mUrl, type: String
  field :mCode, type: String
  field :rCode, type: String
  field :hCode, type: String
  field :mHost, type: String
  field :mUserid, type: String
  field :state, type: String
  index({ mCode: 1 }, { unique: false})

  validates_presence_of :mUserid, :message => "is empty"
  
  # 1. DB입력
  def self.create_hoolike(mParam)
		hoolike = Hoolike.new
		hoolike.mUrl		= mParam["mUrl"]
		hoolike.mCode		= mParam["mCode"]
		hoolike.rCode		= mParam["rCode"]
		hoolike.hCode		= mParam["hCode"]
		hoolike.mHost	= mParam["mHost"]
		hoolike.mUserid	= mParam["mUserid"]
		hoolike.state	= 1
	
    if hoolike.valid?
      hoolike.save
      Meet.incHoo(mParam["mCode"]) if mParam["mCode"] != ""
      Review.incHoo(mParam["rCode"]) if mParam["rCode"] != ""
      Hope.incHoo(mParam["hCode"]) if mParam["hCode"] != ""
    else
      returnmsg = ""
      hoolike.errors.full_messages.each do |msg|
        returnmsg += msg+"\n"
      end
      returnmsg
    end
  end

  def self.delhoolike(mParam)
    @cnt = Hash.new
    if mParam["mCode"] == ""
      Hoolike.where(:mUrl => mParam["mUrl"], :mUserid => mParam["mUserid"]).update_all(:state => 0)
      @cnt[:count] = Hoolike.where(:mUrl => mParam["mUrl"], :state => 1).count
      @cnt[:user] = Hoolike.where(:mUrl => mParam["mUrl"], :mUserid => mParam["mUserid"], :state => 1).count
    else
      Hoolike.where(:mCode => mParam["mCode"], :mUserid => mParam["mUserid"]).update_all(:state => 0)
      @cnt[:count] = Hoolike.where(:mCode => mParam["mCode"], :state => 1).count
      @cnt[:user] = Hoolike.where(:mCode => mParam["mCode"], :mUserid => mParam["mUserid"], :state => 1).count
    end
    Meet.popHoo(mParam["mCode"]) if mParam["mCode"] != ""
    Review.popHoo(mParam["rCode"]) if mParam["rCode"] != ""
    Hope.popHoo(mParam["hCode"]) if mParam["hCode"] != ""
    @cnt
  end
 
  def self.hoocount(mCode)
	  Hoolike.where(:mCode => mCode).count
  end

  def self.hoocountcode(mCode, mUserid)
    @cnt = Hash.new
	  @cnt[:count] = Hoolike.where(:mCode => mCode, :state => 1).count
    @cnt[:user] = Hoolike.where(:mCode => mCode, :mUserid => mUserid, :state => 1).count
    @cnt
  end

  def self.hoocounturl(mUrl, mUserid)
    @cnt = Hash.new
	  @cnt[:count] = Hoolike.where(:mUrl => mUrl, :state => 1).count
    @cnt[:user] = Hoolike.where(:mUrl => mUrl, :mUserid => mUserid, :state => 1).count
    @cnt
  end

  def self.hoolikecode(mCode)
    Hoolike.where(:mCode => mCode, :state => 1).desc(:_id)
  end

  def self.hoolikeurl(mUrl)
    Hoolike.where(:mUrl => mUrl, :state => 1).desc(:_id)
  end

end