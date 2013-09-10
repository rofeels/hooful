#encoding: UTF-8
class LogreportController < ApplicationController
  respond_to :json
  
  def log_status
    @report = Hash.new

	case params[:type]
      when "activity"
	    @report[:pageview] = LogMeetview.pageview(params[:mCode])
	    @report[:share] = 0
	    @report[:hoo] = Hoolike.hoocount(params[:mCode])
	    @report[:talk] = Meetcmt.cmtcount(params[:mCode])
      when "person"
      when "ticket"
	end

	respond_with @report
  end
end
