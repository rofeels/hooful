#encoding: utf-8
class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mCode, type: String
  field :gCategory, type: String
  field :gDate, type: String
  field :gTitle, type: String
  field :gMembers, type: Integer
  field :gPartices, type: Integer
  field :gHost, type: String
  index({ mCode: 1 }, { unique: false})
  has_many :group_members
  has_many :group_talks

  GROUPNUM = 4

  def self.list(params)
    params[:page] ||= 1
    if params[:gDate].blank?
      @egroup = Group.where(mCode: params[:mCode]).skip(GROUPNUM * (params[:page].to_i - 1)).limit(GROUPNUM)
    else
      @egroup = Group.where(mCode: params[:mCode], gDate: params[:gDate]).skip(GROUPNUM * (params[:page].to_i - 1)).limit(GROUPNUM)
    end
  end
  def members
	
    @members = []
    GroupMember.where(:group_id => self._id).each_with_index do |member,index|
      uinfo = User.info(member.mUserid)
      mtmp = Hash.new
      mtmp[:name] = uinfo.name
      mtmp[:picture] = uinfo.picture
      mtmp[:userid] = uinfo.userid
      mtmp[:link] = Home.encode(uinfo.userid)
      mtmp[:members] = uinfo.members
      @members << mtmp
    end	
    @members
  end
end