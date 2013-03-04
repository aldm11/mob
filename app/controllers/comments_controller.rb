class CommentsController < ApplicationController

  def new
    @phone_data = PhoneData.new(current_account, params[:phone_id])
    respond_to do |format|
      format.js          
    end
  end
  
  def create
    @comment = current_account.comments.build(params[:comment])
    @comment.context = Phone.find(params[:phone_id])
    
    @saved = @comment.save
 
    respond_to do |format|
      format.js
    end
  end
  
end