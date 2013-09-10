# coding : utf-8
#encoding: UTF-8
include ActionView::Helpers::DateHelper#time_ago_in_words
class TohoofulController < ApplicationController
  respond_to :json
	before_filter :authorize_update, :only => [:update]
	REVIEW_LIMIT = 2
	TEXT_LIMIT = 50

  def authorize_update
    @review = Tohooful.get_question_detail(params[:rCode])
    if @review.nil? or @review.mWriter != session[:user_id]
          flash[:notice] = "접근 권한이 없습니다."
          redirect_to "/home"
    end
  end


  def create
	  @create_review = Tohooful.create_question(params)
	  render :json => [{:result => @create_review.to_json}]
  end

  def show
    review = Tohooful.get_question_detail(params[:id])
    writer = User.info(review.userid)
    half_type = (review.created_at.strftime("%P") == "am") ? "오전" : "오후"
    review["stime"] = review.created_at.strftime("%m-%d #{half_type} %l:%M")
	  review["link"] = Home.encode(writer.userid)
	  review["picture"] = writer.picture
	  review["name"] = writer.name
	  respond_with review
  end

  def update
    if params[:hMethod] == "edit"
      @update_review = Review.update_review(params)
      if @update_review[:result] == true
		user = User.info(session[:user_id])
        HardWorker.tweet(params,user,'meet') if params["tuid"]== '1'
        HardWorker.fbfeed(params,user,'meet') if params["fuid"]=='1'
        params[:id] = @update_review[:_id]
      elsif @update_review[:result] == false
        flash[:notice] = "오류가 발생했습니다. 후기가 수정되지 않았습니다."
        redirect_to :controller => 'review', :action => 'index'
      else
        flash[:notice] = "작성된 내용이 부족합니다. 후기가 수정되지 않았습니다."
        redirect_to :back
      end
	  end
  end

  def index
		@stohooful = Tohooful.where(:userid => params[:userid]).desc(:created_at)
    @tohooful = []
    @stohooful.each do |tohooful|
      half_type = (tohooful.created_at.strftime("%P") == "am") ? "오전" : "오후"
      tohooful["stime"] = tohooful.created_at.strftime("%m-%d #{half_type} %l:%M")
      @tohooful << tohooful
    end
	  respond_with @tohooful
  end
end
