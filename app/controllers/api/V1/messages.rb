require "sinatra"

module Api
  module V1
    class Messages < Sinatra::Base
      
      get "/received" do
        from = params[:from] ? params[:from].to_i : nil
        to = params[:to] ? params[:to].to_i : nil
        received = Managers::MessageManager.get_messages(current_account, :received, {:search_term => params[:search_term] || nil, :from => from, :to => to, :sort_by => "date"})
        
        inbox = [:related]
        unread_count = @received[:unread_count]
        inbox_to = @received[:to]
        
       response = {:from => from, :to => inbox_to, :unread_count => unread_count}
       response[:messages] = inbox.map { |message| message.get_hash }
       response 
      end
      
      get "sent" do 
        
      end
      
      get "/*" do
        
      end
      
    end
  end
end
