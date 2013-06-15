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
  end
  
  def create
    
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
  
end
