#encoding: UTF-8
class CommunityDocumentController < ApplicationController
  respond_to :json
  
  def index
    @cDoc = CommunityDocument.load(params[:mCode])
	  respond_with @cDoc
  end

  def show
    respond_with CommunityDocument.where(:_id => params[:id])
  end

  def create
    @cDoc = CommunityDocument.create_doc(params)
	session[:user_id] = params[:mUserid] if params[:mUserid]
    render :json => [{:result => @cDoc.to_json}]
  end

end
