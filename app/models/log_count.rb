class LogCount
  include Mongoid::Document
  include Mongoid::Timestamps
  field :datetime, type: String
  field :userview, type: Integer
  field :pageview, type: Integer

  def self.savelog(params)
	datetime = Date.today.strftime('%Y%m%d')
	if LogCount.where(datetime: datetime).exists?
		
		if params[:userid].blank? or params[:userid].nil?
			uservalid = LogPageview.where(ip: params[:ip] , :created_at.gte => Time.new(Date.today.strftime('%Y'), Date.today.strftime('%m'), Date.today.strftime('%d'))).exists?
		else
			uservalid = LogPageview.where(userid: params[:userid] , :created_at.gte => Time.new(Date.today.strftime('%Y'), Date.today.strftime('%m'), Date.today.strftime('%d'))).exists?
		end
		
		LogCount.where(datetime: datetime).first.inc(:pageview, 1)
		if uservalid == false
			LogCount.where(datetime: datetime).first.inc(:userview, 1)
		end
	else
=begin		
		create! do |logcount|
		  logcount.datetime			= datetime
		  logcount.userview			= 1
		  logcount.pageview			= 1
		end
=end
	end
  end
end
