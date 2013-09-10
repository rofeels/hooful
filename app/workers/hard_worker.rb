#encoding: utf-8
class HardWorker
	include Sidekiq::Worker
	
  def self.tweet(meet,user,type)
		if user.tauth and user.tsecret
        consumer = OAuth::Consumer.new(TWITTER_KEY, TWITTER_SECRET,{:site => "http://api.twitter.com"})
        token_hash ={ :oauth_token => user.tauth, :oauth_token_secret => user.tsecret }
        @access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
    
		basis = (meet[:mTimeS].to_i > 12)?"#{(meet[:mTimeS].to_i-12)}:00" : "#{meet[:mTimeS]}:00"
		basis = (meet[:mTimeS].to_i >= 12)?"#{basis} PM" : "#{basis} AM"

		meet[:mTime] = I18n.l(Date.strptime(meet[:mDate], "%Y-%m-%d"), :format => '%m월 %d일') + " " + basis
		meet[:mPicture] = (meet[:mPicture].blank?)? "meetpic/noimage.png" : "meetpic/thumb/#{meet[:mPicture]}"
		
		@twit = Hash.new
		@twit =  "#{meet[:mTitle]}\n- 장소 : #{meet[:mPlace]}\n- 일시 : #{meet[:mTime]}\n- 인원 : #{meet[:mMaxperson]}명\n #Hooful http://www.hooful.com/#{meet[:mCode]}"

		if type=="review"
			@twit =  "[#{meet[:mTitle]}] 모임후기 #Hooful http://www.hooful.com/review/#{meet[:id]}"
		end

        @response = @access_token.request(:post, "http://api.twitter.com/1/statuses/update.json", :status =>@twit)
		Snslog.create!(:type => "twitter",:result => @response.inspect, :contents => @twit)
        
    end    
  end
  
  def self.fbfeed(meet,user,type)
    if !user.fbauth.blank?
      description = meet[:mDescription].gsub(/<\/?[^>]*>/, "")
      app = FbGraph::Application.new(FACEBOOK_KEY, :secret => FACEBOOK_SECRET)
      result = app.debug_token user.fbauth
			@result = nil
      if result.error.nil?
				me = FbGraph::User.me(user.fbauth)

				basis = (meet[:mTimeS].to_i > 12)?"#{(meet[:mTimeS].to_i-12)}:00" : "#{meet[:mTimeS]}:00"
				basis = (meet[:mTimeS].to_i >= 12)?"#{basis} PM" : "#{basis} AM"

				meet[:mTime] = I18n.l(Date.strptime(meet[:mDate], "%Y-%m-%d"), :format => '%m월 %d일') + " " + basis
				meet[:mPicture] = (meet[:mPicture].blank?)? "meetpic/noimage.png" : "meetpic/thumb/#{meet[:mPicture]}"
				
				@feed = Hash.new
				@feed[:message] = "#{meet[:mTitle]}\n- 장소 : #{meet[:mPlace]}\n- 일시 : #{meet[:mTime]}\n- 인원 : #{meet[:mMaxperson]}명"
				@feed[:name] = "Hooful :: #{meet[:mTitle]}"
				@feed[:caption] = "www.hooful.com/#{meet[:mCode]}"
				@feed[:description] = "#{meet[:mDescription].gsub(/<[^>]*>/ui,'')}"
				@feed[:picture] = S3ADDR + meet[:mPicture]
				@feed[:link] = "https://www.hooful.com/#{meet[:mCode]}"

				if type=="review"
					meet[:mPicture] = (meet[:mPicture].blank?)? "reviewpic/noimage.png" : "reviewpic/#{meet[:mPicture]}"
					@feed[:message] = "[#{meet[:mTitle]}] 모임후기"
					@feed[:name] = "Hooful :: #{meet[:mTitle]} :: 모임후기"
					@feed[:caption] = "www.hooful.com/review/#{meet[:id]}"
					@feed[:description] = "#{meet[:mReview].gsub(/<[^>]*>/ui,'')}"
					@feed[:picture] = S3ADDR + meet[:mPicture]
					@feed[:link] = "http://www.hooful.com/review/#{meet[:id]}"
				end
				begin
					@response = me.feed!(
						:message => @feed[:message], 
						:name =>@feed[:name], 
						:caption => @feed[:caption], 
						:description => @feed[:description], 
						:picture => @feed[:picture], 
						:link => @feed[:link]
					)
					Snslog.create!(:type => "fb",:result => @response.inspect)
				rescue FbGraph::Unauthorized => e
						@result = "NO"
				end
			else
				@result = "NO"
	    end
      return @result
    end
  end

end