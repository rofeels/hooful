#encoding: UTF-8
class Guestbook
  include Mongoid::Document
  include Mongoid::Timestamps
  field :gHostid, type: String
  field :mCategory, type: String
  field :mCode, type: String
  field :mTitle, type: String
  field :gMsg, type: String
  field :gUserid, type: String

  def userinfo
	User.info(self.gUserid)
  end

  def self.cmtcount(rCode)
	Guestbook.where(:gHostid => gHostid).count
  end

end