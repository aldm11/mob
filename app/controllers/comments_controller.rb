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
      @all_comments_count = phone.comments.select {|comm| comm.active}.length unless phone.comments.empty?
    end
 
    respond_to do |format|
      format.js
    end
  end
  
  def show_next_page
    from = params[:from].to_i || 0
    size = params[:size].to_i || 10
    
    phone = Phone.find(params[:phone_id])
    @all_comments = phone.comments.select {|comm| comm.active}.sort {|a, b| b.created_at <=> a.created_at}
    @to = from + size - 1
    @to = @all_comments.length-1 if @to > @all_comments.length - 1
    @comments = @all_comments[from..@to]
  end
  
end