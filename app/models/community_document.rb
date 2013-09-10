class CommunityDocument
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCategory, type: String
  field :mUserid, type: String
  field :mTitle, type: String
  field :mContents, type: String
  field :mPicture, type: String
  field :mDate, type: String
  field :mTime, type: String
  index({ mCategory: 1 }, { unique: false})

  validates_presence_of :mCategory, :mTitle, :mContents, :message => "is empty"

  def self.create_doc(mParam)
		cdoc = CommunityDocument.new
		cdoc.mCategory		= mParam["mCategory"]
		cdoc.mUserid		= mParam["mUserid"]
		cdoc.mTitle	= mParam["mTitle"]
		cdoc.mContents	= mParam["mContents"]
		cdoc.mPicture	= mParam["mPicture"]
		cdoc.mDate		= Time.now.strftime("%Y. %m. %d")
		cdoc.mTime	= Time.now.strftime("%H:%M")
	
    if cdoc.valid?
      cdoc.save
    else
      returnmsg = ""
      cdoc.errors.full_messages.each do |msg|
        returnmsg += msg+"\n"
      end
      returnmsg
    end
  end

  def self.load(mcode)
	  meet = CommunityDocument.where(:mCategory => mcode).desc(:_id)
  end

  def self.get_review_detail(idx)
	  review = CommunityDocument.where(:_id => idx).first
  end

end
