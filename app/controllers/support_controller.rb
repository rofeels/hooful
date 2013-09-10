#encoding: utf-8
class SupportController < ApplicationController

  def index
   @bg = "hooful"
  end

  def notice
   @bg = "bbs"
  end
  def instructions
   @bg = "support"
  end

  def hooful
   @bg = "bbs"
	if session[:user_id] and session[:user_id] == 'hooful@hooful.com'
		@questions = Tohooful.all.desc(:created_at)
		@listset = Hash.new
		@listset[:qustioner] = '<'
	elsif session[:user_id]		
		@listset = nil
		@questions = Tohooful.where(:userid => session[:user_id]).asc(:updated_at)
	else
		@questions = Array.new
	end
	if @questions.length > 0
		@questions.each do |q|
			if q.answerTime.nil?
				q.answerTime = "미답변"
			end
			q["answerTime"] = "미답변"
		end
		@questions
	else
		@questions = nil
	end
	return @questions
  end

  def tohoofulnew
   @bg = "support"
	if params
		params[:userAgent] = request.env['HTTP_USER_AGENT']
		params[:userid] = (session[:user_id]) ? session[:user_id] : "empty"
		tohooful = Tohooful.create_question(params)
		if tohooful.save
			flash[:notice] = "후풀에게 전송 되었습니다."
		else
			flash[:notice] = "다시 시도해 주시기 바랍니다."
		end
	else
		flash[:notice] = "다시 시도해 주시기 바랍니다."
	end
	redirect_to :controller => "support", :action => "hooful"
  end

  def tohoofuladmin
   @bg = "support"
	if params
		if session[:user_id] and session[:user_id] == 'hooful@hooful.com'
			result = Tohooful.answer_question(params)
		end
	end
	if result
		flash[:notice] = "답변이 등록되었습니다."
	else
		flash[:notice] = "다시 시도해 주세요."
	end
	redirect_to :controller => "support", :action => "hooful"
  end

  def partner
   @bg = "bbs"
  end

  def terms
    @bg = "bbs"
  end

  def privacy
    @bg = "bbs"
  end

  def faq
    @bg = "bbs"
  end

end
