#encoding: utf-8
class GroupMember
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mUserid, type: String
  field :mCode, type: String

  belongs_to  :group, autosave: true, index: true
  has_many  :group_talks, autosave: true
  validates_uniqueness_of :mUserid, :scope => :group_id

  def self.addMember(userid, gid)
	Notification.send("group_new_mbr", userid, gid,"")
    @group_member = GroupMember.new(:mUserid => userid, :group_id => gid)
	if @group_member.valid?
		@group_member.save
	else
		@group_member = GroupMember.where(:mUserid => userid, :group_id => gid).first
	end
	@group_member
  end
end