#encoding: utf-8
class Mplog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mpaction, type: String		
  field :reqbody, type: String		
  field :body, type: String		

  def self.create_log(mpaction, reqbody, resbody)
		@payhistory = Mplog.create(
			:mpaction => mpaction,
			:reqbody => reqbody,
			:body => resbody
		)
	end
end
