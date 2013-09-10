class LogController < ApplicationController

	def Pageview
		params[:agent] = request.env["HTTP_USER_AGENT"]
		params[:language] = request.env["HTTP_ACCEPT_LANGUAGE"]
		params[:userid] = request.env["rack.session"]["user_id"]
		params[:ip] = request.env["HTTP_X_FORWARDED_FOR"]
	  	@pageview = LogPageview.savelog(params)
	  	@viewcount = LogCount.savelog(params)
		respond_to do |format|
			if @pageview
				format.json  { render :json => {:result => @pageview.id}, :status => :created }
			else
				format.json  { render :json => {:result => "faild"}, :status => :created }
			end	  	
		end
	end
	
	def Loadtime
	  	@pageview = LogPageview.save_loadedtime(params)	   	
		respond_to do |format|
			if @pageview
				format.json  { render :json => {:result => "success"}, :status => :created }
			else
				format.json  { render :json => {:result => "faild"}, :status => :created }
			end	  	
		end 	
	end	
	
	def Endtime
	  	@pageview = LogPageview.save_endedtime(params)	
		respond_to do |format|
			if @pageview
				format.json  { render :json => {:result => @pageview.id}, :status => :created }
			else
				format.json  { render :json => {:result => "faild"}, :status => :created }
			end	  	
		end
	end	
	
end
