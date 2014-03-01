class CommentsController < ApplicationController
  before_filter :only_signed_in_users, :only => ["create"]
  def new
    @phone_data = PhoneData.new(current_account, params[:phone_id])
    respond_to do |format|
      format.js          
    end
  end
  
  def create 
    phone = Phone.find(params[:phone_id])
    @result = Managers::CommentManager.create(current_account, params[:comment][:text], :phone => phone)
    @all_comments_count = phone.comments.select {|comm| comm.active}.length unless phone.comments.empty?
    
    if params[:phone_popup] == "1"
      render "create_from_popup"
    else
      render "create"
    end
  end
  
  def show_next_page
    from = params[:from].to_i || 0
    size = params[:size].to_i || 10
    
    @to = from + size - 1
    
    comments_details = Managers::PhoneManager.get_comments(params[:phone_id], {:from => from, :to => @to, :sort_by => "date"})
    @all_comments = comments_details[:all_comments]
    @comments = comments_details[:related_comments]
    @to = comments_details[:to]
  end
  
end