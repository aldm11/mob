class MessagesController < ApplicationController
  before_filter :only_signed_in_users
  
  def index
    @received = Managers::MessageManager.get_messages(current_account, :received, {:search_term => nil, :from => 0, :to => 2, :sort_by => "date"})
    @sent = Managers::MessageManager.get_messages(current_account, :sent, {:search_term => nil, :from => 0, :to => 2, :sort_by => "date"})
    
    @inbox = @received[:related]
    @outbox = @sent[:related]
    @unread_count = @received[:unread_count]
    @inbox_to = @received[:to]
    @outbox_to = @sent[:to]
  end
  
  def new
    @received = Managers::MessageManager.get_messages(current_account, :received, {:search_term => nil, :from => 0, :to => 2, :sort_by => "date"})
    @sent = Managers::MessageManager.get_messages(current_account, :sent, {:search_term => nil, :from => 0, :to => 2, :sort_by => "date"})
    
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
  
  def pre_remove
    respond_to {|format| format.js}
  end
  
  def remove
    @message_id = params[:message_id]
    @type = params[:type]
    @result = Managers::MessageManager.delete_message(current_account, @type, @message_id)
    
    respond_to {|format| format.js}
  end
  
  RECEIVED_TYPE = "received"
  SENT_TYPE = "sent"
  def show_next_page
    type = params[:type]
    search_term = params[:search_term] || nil
    from = params[:from] ? params[:from].to_i : 0
    size = params[:size] ? params[:size].to_i : 3
    to = from + size - 1
    sort_by = params[:sort_by] || "date"
    
    if type == RECEIVED_TYPE
      received = Managers::MessageManager.get_messages(current_account, :received, {:search_term => search_term, :from => from, :to => to, :sort_by => sort_by})
      #raise received[:all].inspect+" "+received[:related].inspect
      @view = "messages/inbox"
      @container = ".messages.received"
      @params = {:page_inbox => received[:related], :inbox => received[:all], :from => from, :to => to}
    elsif type == SENT_TYPE
      sent = Managers::MessageManager.get_messages(current_account, :sent, {:search_term => search_term, :from => from, :to => to, :sort_by => sort_by})
      @view = "messages/outbox"
      @container = ".messages.sent"
      @params = {:page_outbox => sent[:related], :outbox => sent[:all], :from => from, :to => to}
    end
  end
  
  def read
    
  end
  
  def bulk_delete
    
  end
  
  def receiver_id_remote
    @account_id = Account.where(username: params[:username]).to_a.first.id.to_s
  end
  
end
