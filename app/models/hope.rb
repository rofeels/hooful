class Hope
  include Mongoid::Document
  include Mongoid::Timestamps
  field :rCode, type: String
  field :mCode, type: String
  field :mWriter, type: String
  field :mPicture, type: String
  field :mPicturename, type: String
  field :mTitle, type: String
  field :mContent, type: String
  field :mWhen, type: String
  field :mWhere, type: String
  field :mWhat, type: String
  field :uHoo, type: Integer
  field :uCmtcnt, type: Integer
  index({ mCode: 1 }, { unique: false})

  validates_presence_of :mWriter, :mTitle, :rCode, :message => "is empty"
  validates_uniqueness_of :rCode

# 1. 원하는모임생성 - DB입력
  def self.create_hope(mParam)
    if mParam["mPicture"]=="noimage.png"
      mParam["mPicture"] = ""
      mParam["mPicturename"] = ""
    end
    
    begin
      codeGenerate =  [(0..9),('A'..'Z')].map{|i| i.to_a}.flatten
      rCode  =  (0...5).map{ codeGenerate[rand(codeGenerate.length)] }.join
      
	  hope = Hope.new
	  hope.rCode		= rCode
	  hope.mCode		= mParam["mCode"]		
	  hope.mWriter		= mParam["mWriter"]
	  hope.mTitle	= mParam["mTitle"]
	  hope.mContent	= mParam["mContent"]
	  hope.mWhen	= mParam["mWhen"]
	  hope.mWhere	= mParam["mWhere"]
	  hope.mWhat	= mParam["mWhat"]
	  hope.mPicture		= mParam["mPicture"]
	  hope.mPicturename	= mParam["mPicturename"]
	  hope.uHoo = 0
    hope.uCmtcnt = 0

    end while !hope.valid? 
        		
    if hope.valid?
      hope.save
    else
      returnmsg = ""
      hope.errors.full_messages.each do |msg|
        returnmsg += msg+"\n"
      end
      returnmsg
    end
  end

  def self.update_hope(mParam)
    if mParam["mPicture"]=="noimage.png"
      mParam["mPicture"] = ""
      mParam["mPicturename"] = ""
    end

    ureview = {
      "mCode" =>	mParam["mCode"],
      "mWriter" =>	mParam["mWriter"],
      "mContent" =>	mParam["mContent"],
      "mWhen" =>	mParam["mWhen"],
      "mWhere" =>	mParam["mWhere"],
      "mWhat" =>	mParam["mWhat"],
      "mPicture" => mParam["mPicture"],
      "mPicturename" => mParam["mPicturename"]
    }
    ucode = {
      "_id" =>	mParam["id"]
    }
    Hope.where(rCode: mParam["id"]).update_all(ureview)
    @result = Hope.get_hope_detail(mParam["id"])
  end

  def self.load
	  hope = all.desc(:_id)
  end

  def self.get_hope_detail(rcode)
	  hope = Hope.where(rCode: rcode).first
  end

  # inc/dec Count
  def self.incHoo(rCode)
    Hope.where(:rCode => rCode).last.inc(:uHoo, 1)
  end
  def self.popHoo(rCode)
    Hope.where(:rCode => rCode).last.inc(:uHoo, -1)
  end
  def self.incCmt(rCode)
    Hope.where(:rCode => rCode).last.inc(:uCmtcnt, 1)
  end
  def self.popCmt(rCode)
    Hope.where(:rCode => rCode).last.inc(:uCmtcnt, -1)
  end
end
