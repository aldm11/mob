module Managers
  module MessageManager
    INVALID_PARAMS_RESULT = {:status => false, :message => nil, :text => "Invalid parameters"}
    
    ### function for sending message
    ### PARAMETERS: 
    ### =>  current_account  - id or model of account logged in
    ### =>  to               - id or model of account to send message to
    ### =>  mess             - message text or
    ### =>  options          - additional options for extending, currently not used    
    ### TODO: consider if want to forbid spam messages, to restrict sending message with same text sender and reveicer in 30 sec time frame              
    def self.send_message(current_account, to, mess, options = {})
      return INVALID_PARAMS_RESULT if current_account.blank? || to.blank? || mess.blank? || !mess.is_a?(String)
      
      sender = nil
      begin
        sender = current_account.is_a?(Account) ? current_account : Account.find(current_account.to_s)
        receiver = to.is_a?(Account) ? to : Account.find(to.to_s)
      rescue Exception => ex
        return INVALID_PARAMS_RESULT
      end
      
      message1 = sender.sent_messages.build(:text => mess, :sender_id => sender.id, :receiver_id => receiver.id)
      message2 = receiver.received_messages.build(:id => message1.id, :text => mess, :sender_id => sender.id, :receiver_id => receiver.id)
      
      if message1.save && message2.save
        return {:status => true, :message => message1, :text => "Message sent"}
      else
        return {:status => false, :message => message1, :text => "Message invalid"}
      end
    end
    
    ### function for updating sent message - message could be updated in 3 minutes after sending
    ### PARAMETERS
    ### =>  current_account - id or model of account logged in
    ### =>  message_id      - id or model of message
    ### =>  options         - currently not used, for extending
    def self.quick_update(current_account, mess, options = {})
      return INVALID_PARAMS_RESULT if current_account.blank? || mess.blank? || !mess.is_a?(Message)
      
      begin
        sender = current_account.is_a?(Account) ? current_account : Account.find(current_account.to_s)
        old_message = sender.sent_messages.select { |m| m.id.to_s == mess.id.to_s }.first
        receiver = Account.find(old_message.receiver_id.to_s)
      rescue Exception => ex
        return {:status => false, :message => mess, :text => "Access denied"}
      end
            
      edit_enabled = 3 * 60     
      current_timestamp = Time.now.utc.to_time.to_i
      
      return {:status => false, :message => mess, :text => "Message can be edited in #{(edit_enabled/60).to_s} minutes after sent" } if (current_timestamp - old_message.date_sent.utc.to_time.to_i) > edit_enabled
    
      message_receiver = receiver.received_messages.select {|m| m.id.to_s == mess.id }.first
      message_receiver.text = mess.text
      if mess.save && message_receiver.save
        return {:status => true, :message => mess, :text => "Message updated"}
      else
        return {:status => false, :message => mess, :text => "Message invalid"}
      end
    end
    
    ### function to read message
    ### PARAMETERS
    ### =>  current_account   - id or model of account logged in
    ### =>  mess              - id or model of message to be read
    def self.read_message(current_account, mess)      
      return INVALID_PARAMS_RESULT if current_account.blank? || mess.blank?
      
      begin
        receiver = current_account.is_a?(Account) ? current_account : Account.find(current_account)
        mess_id = mess.is_a?(Message) ? mess.id.to_s : mess.to_s
        message = receiver.received_messages.select {|m| m.id.to_s == mess_id}.first
        sender = Account.find(message.sender_id.to_s)
      rescue Exception
        return {:status => false, :message => mess, :text => "Access denied"} 
      end
      
      message_sender = sender.sent_messages.select {|m| m.id.to_s == mess_id }.first  
      message.date_read = Time.now.utc.to_time.to_i
      message_sender.date_read = Time.now.utc.to_time.to_i
      
      if message.save && message_sender.save
        return {:status => true, :message => message, :text => "Message read"}
      else
        return {:status => false, :message => message, :text => "Message invalid"}
      end
    end
    
  end
end