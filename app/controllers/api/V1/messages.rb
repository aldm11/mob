module Api
  module V1
    class Messages < Base
      get "/received" do
        require_authorization
        
        get_messages(:received).to_json
      end
      
      get "/sent" do 
        require_authorization
        
        get_messages(:sent).to_json
      end
      
      post "/" do
        require_authorization
        
        receiver_id = parameters[:to] || nil
        text = parameters[:text] || nil
        reply_to = parameters[:reply_to] || nil
        
        halt 400, "to and text are required" if receiver_id.blank? || text.blank?
        
        result = Managers::MessageManager.send_message(@account, receiver_id, text, {:reply_to => reply_to})
        halt 400, result[:text] unless result[:status]
        
        MessageDecorator.decorate(result[:message]).get_hash.to_json
      end
      
      
      get "/*" do
        require_authorization
        
        message_id = params[:splat].first
        type = parameters[:type] || nil
                
        conversation = Managers::MessageManager.get_conversation(@account, type, message_id)        
        halt 400, "Conversation not found" if conversation.empty? || (conversation.is_a?(Hash) && !conversation[:status])
        
        target_message = conversation.select{|m| m.id.to_s == message_id }.to_a.first
        other_part = type.to_s == "received" ? target_message.sender_id : target_message.receiver_id
        
        read_result = target_message.date_read.nil? ? Managers::MessageManager.read_message(@account, target_message) : nil
        
        response = {}
        response[:messages] = conversation.map! { |message| MessageDecorator.decorate(message).get_hash }
        response.to_json
      end
      
      private
      def get_messages(type)
        from = parameters[:from] ? parameters[:from].to_i : 0
        to = parameters[:to] ? parameters[:to].to_i : nil
        
        received = Managers::MessageManager.get_messages(@account, type.to_sym, {:search_term => parameters[:search_term] || nil, :from => from, :to => to, :sort_by => "date"})
        inbox = received[:related]
        unread_count = received[:unread_count]
        inbox_to = received[:to]
        
        response = {:from => from, :to => inbox_to, :unread_count => unread_count}
        response[:messages] = inbox.map { |message| MessageDecorator.decorate(message).get_hash }
        response
      end
  
    end
  end
end
