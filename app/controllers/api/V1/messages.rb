require "sinatra"

module Api
  module V1
    class Messages < Sinatra::Base
      before do
        headers "Content-Type"=> "text/json"
        authenticate_user
      end
      
      get "/received" do
        get_messages(:received).to_json
      end
      
      get "/sent" do 
        get_messages(:sent).to_json
      end
      
      post "/" do
        receiver_id = get_params[:to] || nil
        text = get_params[:text] || nil
        reply_to = get_params[:reply_to] || nil
        
        halt 400, "to and text are required" if receiver_id.blank? || text.blank?
        
        result = Managers::MessageManager.send_message(@account, receiver_id, text, {:reply_to => reply_to})
        halt 400, result[:text] unless result[:status]
        
        MessageDecorator.decorate(result[:message]).get_hash.to_json
      end
      
      
      get "/*" do
        message_id = get_params[:splat].first
        type = get_params[:type] || nil
        conversation = Managers::MessageManager.get_conversation(@account, type, message_id)
        
        halt 400, "Conversation not found" if conversation.is_a?(Hash) && !conversation[:status]
        target_message = conversation.select{|m| m.id.to_s == message_id }.to_a.first
        other_part = type.to_s == "received" ? target_message.sender_id : target_message.receiver_id
        
        read_result = target_message.date_read.nil? ? Managers::MessageManager.read_message(@account, target_message) : nil
        
        response = {}
        response[:messages] = conversation.map! { |message| MessageDecorator.decorate(message).get_hash }
        response.to_json
      end
      
      def get_messages(type)
        from = get_params[:from] ? get_params[:from].to_i : nil
        to = get_params[:to] ? get_params[:to].to_i : nil
        
        received = Managers::MessageManager.get_messages(@account, type.to_sym, {:search_term => params[:search_term] || nil, :from => from, :to => to, :sort_by => "date"})
        inbox = received[:related]
        unread_count = received[:unread_count]
        inbox_to = received[:to]
        
        response = {:from => from, :to => inbox_to, :unread_count => unread_count}
        response[:messages] = inbox.map { |message| MessageDecorator.decorate(message).get_hash }
        response
      end
      
      def authenticate_user        
        auth_header = env["HTTP_AUTHORIZATION"]
        @account = nil
        if auth_header && auth_header.start_with?("Basic")
          email, password = auth_header.sub("Basic ", "").split(":")
          @account = Account.find_for_database_authentication(:email => email)
          @account = nil unless @account && @account.valid_password?(password)
        elsif auth_header && auth_header.start_with?("Cookie") && env["warden"].authenticated?
          @account = env["warden"].user
        end
        
        halt 401, "Unauthorized client" unless @account 
      end
      
      def get_params
        request.body.rewind
        body = request.body.read
        body = body.blank? ? nil : JSON.parse(body)
        result = env["action_dispatch.request.path_parameters"]
        result.merge!(body) if body
        result.with_indifferent_access
      end
      
      def path 
        env["PATH_INFO"]
      end
      
    end
  end
end
