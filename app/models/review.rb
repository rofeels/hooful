class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  field :rCode, type: String
  field :mCode, type: String
  field :mWriter, type: String
  field :mPicture, type: String
  field :mPicturename, type: String
  field :mTitle, type: String
  field :mReview, type: String
  field :uHoo, type: Integer
  field :uCmtcnt, type: Integer
  index({ mCode: 1 }, { unique: false})

  validates_presence_of :mCode, :mWriter, :mReview, :mTitle, :rCode, :message => "is empty"
  validates_uniqueness_of :rCode

# 1. 모임후기생성 - DB입력
  def self.create_review(mParam)
	if mParam["mPicture"]=="noimage.png"
		mParam["mPicture"] = ""
		mParam["mPicturename"] = ""
	end

	
    begin
      codeGenerate =  [(0..9),('A'..'Z')].map{|i| i.to_a}.flatten
      rCode  =  (0...5).map{ codeGenerate[rand(codeGenerate.length)] }.join
      
	  review = Review.new
	  review.rCode		= rCode
	  review.mCode		= mParam["mCode"]		
	  review.mWriter		= mParam["mWriter"]
	  review.mTitle	= mParam["mTitle"]
	  review.mReview	= mParam["mReview"]
	  review.mPicture		= mParam["mPicture"]
	  review.mPicturename	= mParam["mPicturename"]
	  review.uHoo = 0
    review.uCmtcnt = 0

    end while !review.valid? 
        		
	if review.valid?
		review.save
	else
		returnmsg = ""
		review.errors.full_messages.each do |msg|
			returnmsg += msg+"\n"
		end
		returnmsg
	end
  end

  def self.update_review(mParam)
		if mParam["mPicture"]=="noimage.png"
			mParam["mPicture"] = ""
			mParam["mPicturename"] = ""
		end

	ureview = {
		"mCode" =>	mParam["mCode"],
		"mWriter" =>	mParam["mWriter"],
		"mReview" =>	mParam["mReview"],
		"mPicture" => mParam["mPicture"],
		"mPicturename" => mParam["mPicturename"]
	}
	ucode = {
		"_id" =>	mParam["id"]
	}
    Review.where(rCode: mParam["id"]).update_all(ureview)
    @result = Review.get_review_detail(mParam["id"])
  end

  def self.load
	meet = all.desc(:_id)
  end

  def self.get_review_detail(rcode)
	review = Review.where(rCode: rcode).first
  end

  # inc/dec Count
  def self.incHoo(rCode)
    Review.where(:rCode => rCode).last.inc(:uHoo, 1)
  end
  def self.popHoo(rCode)
    Review.where(:rCode => rCode).last.inc(:uHoo, -1)
  end
  def self.incCmt(rCode)
    Review.where(:rCode => rCode).last.inc(:uCmtcnt, 1)
  end
  def self.popCmt(rCode)
    Review.where(:rCode => rCode).last.inc(:uCmtcnt, -1)
  end
end
