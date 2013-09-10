class InterestController < ApplicationController
  respond_to :json

  def index
    respond_with Interest.all
  end
=begin
  def show
    respond_with Interest.find(params[:id])
  end

  def create
    respond_with Interest.create(params[:Interest])
  end

  def update
    respond_with Interest.update(params[:id], params[:Interest])
  end

  def destroy
    respond_with Interest.destroy(params[:id])
  end
=end
end
