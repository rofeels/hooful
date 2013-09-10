#encoding: UTF-8
class Reviewcmt
  include Mongoid::Document
  include Mongoid::Timestamps
  field :rCode, type: String
  field :rMsg, type: String
  field :rUserid, type: String

  def userinfo
	User.info(self.rUserid)
  end

  def self.cmtcount(rCode)
	Reviewcmt.where(:rCode => rCode).count
  end

  def self.loadCmt(params)
    talk_limit = 5
    if params[:firstTalk]
      @ehootalk = Reviewcmt.where(:rCode => params[:rCode], :_id.lt =>params[:firstTalk]).desc(:created_at)
    else
      @ehootalk = Reviewcmt.where(:rCode => params[:rCode]).desc(:created_at)
    end
    @hootalk = []
    if @ehootalk.count > talk_limit
      mtmp = Hash.new
      mtmp["prev"] = @ehootalk.count-talk_limit
      @hootalk << mtmp
    end
    @ehootalk = @ehootalk.limit(talk_limit).reverse
    @ehootalk.each do |hootalk|
      hootalk_info = hootalk.userinfo
      mtmp = Hash.new
      mtmp["rid"] = hootalk._id
      mtmp["rCode"] = hootalk.rCode
      mtmp["rMsg"] = hootalk.rMsg
      mtmp["created_at"] = "#{time_ago_in_words(hootalk.created_at)}"
      mtmp["rUserid"] = hootalk.rUserid
      mtmp["userid"] = hootalk_info.userid
      mtmp["link"] = Home.encode(hootalk_info.userid)
      mtmp["picture"] = hootalk_info.picture
      mtmp["name"] = hootalk_info.name
      @hootalk << mtmp
    end
    @hootalk
  end

end