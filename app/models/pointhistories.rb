class Pointhistories
  include Mongoid::Document
  include Mongoid::Timestamps
  field :pType, type: String
  field :pUserid, type: String
  field :pPoint, type: Integer
  field :pTotal, type: Integer
  field :pMessage, type: String
  field :pDate, type: String
  field :pTime, type: String

  def self.create_point(mParam)
    point = Pointhistories.new
		point.pType		= mParam[:pType]
		point.pUserid		= mParam[:pUserid]
		point.pPoint	= mParam[:pPoint]
		point.pTotal	= mParam[:pTotal]
		point.pMessage	= mParam[:pMessage]
		point.pDate		= Time.now.strftime("%Y. %m. %d")
		point.pTime	= Time.now.strftime("%H:%M:%S")
	
    if point.valid?
      point.save
    else
      returnmsg = ""
      point.errors.full_messages.each do |msg|
        returnmsg += msg+"\n"
      end
      returnmsg
    end
  end



end
