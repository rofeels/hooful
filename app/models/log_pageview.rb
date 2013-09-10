class LogPageview
  include Mongoid::Document
  include Mongoid::Timestamps
  field :ip, type: String
  field :userid, type: String
  field :page, type: String
  field :referer, type: String
  field :agent, type: String
  field :language, type: String
  field :resolution, type: String
  field :loaded_at, type: Time
  field :ended_at, type: Time
  
  # 1. 로그생성 - DB입력
  def self.savelog(params)
=begin
	create! do |pageview|		
	  	pageview.ip = params[:ip]
	  	pageview.userid = params[:userid]
		pageview.page = params[:page]
		pageview.referer = params[:referer]
		pageview.agent = params[:agent]
		pageview.language = params[:language]
		pageview.resolution = params[:resolution]
	end
=end
  end
  
  # 2. 페이지로딩시간 - DB 업데이트
  def self.save_loadedtime(params)
  	#LogPageview.where(_id: params[:logid]).update_all("loaded_at" => Time.now)
  end
  
  # 3. 페이지종료시간 - DB 업데이트  
  def self.save_endedtime(params)
  	#LogPageview.where(_id: params[:logid]).update_all("ended_at" => Time.now)
  end
end