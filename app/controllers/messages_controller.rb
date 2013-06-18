class MessagesController < ApplicationController
  before_filter :only_signed_in_users
  
  def index
    @received = Managers::MessageManager.get_messages(current_account, :received, {:from => 0, :to => 2, :sort_by => "date"})
    @sent = Managers::MessageManager.get_messages(current_account, {:from => 0, :to => 2, :sort_by => "date"}, :sent)
    
    @inbox = @received[:related]
    @outbox = @sent[:related]
    @unread_count = @received[:unread_count]
    @inbox_to = @received[:to]
    @outbox_to = @sent[:to]
  end
  
  def new
    @received = Managers::MessageManager.get_messages(current_account, :received, {:from => 0, :to => 2, :sort_by => "date"})
    @sent = Managers::MessageManager.get_messages(current_account, {:from => 0, :to => 2, :sort_by => "date"}, :sent)
    
    @inbox = @received[:related]
    @outbox = @sent[:related]
    @unread_count = @received[:unread_count]
    @inbox_to = @received[:to]
    @outbox_to = @sent[:to]
    
    @receivers_usernames = Account.all.select {|a| a.id.to_s != current_account.id.to_s }.map {|a| a.username}.compact
  end
  
  def create
    @receiver_id = params[:receiver_id] || nil
    @text = params[:text] || nil
    
    @result = nil
    unless @receiver_id.blank? || @text.blank?
      @result = Managers::MessageManager.send_message(current_account, @receiver_id, @text)
    end
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destory
    
  end
  
  def show_next_page
    
  end
  
  def read
    
  end
  
  def bulk_delete
    
  end
  
  def receiver_id_remote
    @account_id = Account.where(username: params[:username]).to_a.first.id.to_s
  end
  
end
