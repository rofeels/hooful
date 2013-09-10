#encoding: UTF-8
include ActionView::Helpers::NumberHelper #number_to_currency
class WithdrawController < ApplicationController
  respond_to :json

  def index
    respond_with Withdraw.index(params)
  end

  def show
    respond_with Withdraw.all
  end

  def create
    respond_with Withdraw.save(params[:mBank], params[:mHolder], params[:mAccount], params[:mUserid], params[:mCode], params[:mPrice])
  end

end
