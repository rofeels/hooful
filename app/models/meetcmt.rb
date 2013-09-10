#encoding: UTF-8
class Meetcmt
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :mMsg, type: String
  field :mHost, type: String
  field :mUserid, type: String
  index({ mCode: 1 }, { unique: false})

  def userinfo
	User.info(self.mUserid)
  end

  def self.cmtcount(mCode)
	Meetcmt.where(:mCode => mCode).count
  end

end