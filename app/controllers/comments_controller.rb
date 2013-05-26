class CommentsController < ApplicationController
  before_filter :only_signed_in_users, :only => ["new", "create"]
  def new
    @phone_data = PhoneData.new(current_account, params[:phone_id])
    respond_to do |format|
      format.js          
    end
  end
  
  def create
    if params[:comment][:text].blank?
      @saved = false
    else
      @comment = current_account.comments.build(params[:comment])
      phone = Phone.find(params[:phone_id])
      @comment.context = phone
      
      @saved = @comment.save
      phone.save
    end
 
    respond_to do |format|
      format.js
    end
  end
  
  def show_next_page
    from = params[:from] || 0
    size = params[:size] || 10
    
    phone = @comments = @phone.comments.select {|comm| comm.active}.sort {|a, b| b.created_at <=> a.created_at} unless @phone.comments.empty?
    @comments = phone.comments.select {|comm| comm.active}.sort {|a, b| b.created_at <=> a.created_at} unless @phone.comments.empty?
    @comments = @comments[from..size]
  end
  
end