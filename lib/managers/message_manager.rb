module Managers
  module MessageManager
    INVALID_PARAMS_RESULT = {:status => false, :message => nil, :text => "Invalid parameters"}
    
    ### SENDING MESSAGE
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
    
    ### UPDATING SENT MESSAGE
    ### message can be updated only in 3 mins after sending
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
    
    ### READING MESSAGE
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
    
    ### GETTING SENT OR RECEIVED MESSAGES
    ### PARAMETERS
    ### =>  current_account - string or model of account logged in
    ### =>  type => sent or received, string or symbol
    ### =>  options - options hash: from, to, sort(date, read)
    DEFAULT_MESSAGES = {:all => [], :related => [], :to => 0, :unread_count => 0}
    def self.get_messages(current_account, type, options = {})
      return DEFAULT_MESSAGES if current_account.blank? || !type || (type.to_s != "received" && type.to_s != "sent")
      
      begin
        account = current_account.is_a?(Account) ? current_account : Account.find(current_account.to_s)
      rescue Exception => e
        return DEFAULT_MESSAGES
      end
      all_messages = type.to_s == "received" ? account.received_messages.select {|m| !m.mark_deleted } : account.sent_messages.select {|m| !m.mark_deleted }
      if options[:search_term]
        term = options[:search_term]
        if type.to_s == "received"
          all_messages = all_messages.select {|m| m.text.include?(term) || m.sender.rolable.name.include?(term)}
        elsif type.to_s == "sent"
          #TODO: add receiver hash attribute to each message ({:receiver_name, :receiver_image, :receiver_id, :receiver_username }) - propagation ??
          all_messages = all_messages.select {|m| m.text.include?(term) || Account.find(m.receiver_id).rolable.name.include?(term) rescue false }
        end
      end
       
      if options[:sort_by] == "date"
        all_messages.sort! {|a,b| b.date_sent <=> a.date_sent }
      elsif options[:sort_by] == "read"
        all_messages.sort! {|a,b| b.date_read.nil? ? 0 : 1 <=> a.date_read.nil? ? 0 : 1 }
      end
      
      if options[:from] && options[:to]
        from = options[:from]
        to = options[:to] 
        to = all_messages.length - 1 if to > all_messages.length - 1
        related_messages = all_messages[from..to]
      else
        to = 0
        related_messages = all_messages
      end
      unread_count = type.to_s == "received" ? all_messages.select {|m| m.date_read.nil?}.length : 0
      
      result = DEFAULT_MESSAGES.merge({:all => all_messages, :related => related_messages, :to => to, :type => type.to_s, :unread_count => unread_count})
      result
    end
    
    ### DELETING ONE MESSAGE WITH ALL VALIDATIONS
    ### if current_account is receiver, message will be removed only from his inbox
    ### if current_account is sender, message will be removed from his and reveicers inbox 
    ### PARAMETERS
    ### =>  current_account - id or model of account logged in
    ### =>  mess            - id or model of mess to be deleted
    ### =>  options         - hash of optional arguments, currently not used
    def self.delete_message(current_account, mess, options = {})
      return INVALID_PARAMS_RESULT if current_account.blank? || mess.blank?
      
      begin
        account = current_account.is_a?(Account) ? current_account : Account.find(current_account.to_s)
      rescue Exception => e
        return {:status => false, :message => mess, :text => "Account not find"}
      end
      
      begin
        message = mess.is_a?(Message) ? mess : Message.find(mess.to_s)
      rescue Exception => e
        return {:status => false, :message => mess, :text => "Message not found"}
      end
      
      remove_message(account, message)    
    end
    
    def self.bulk_delete(current_account, mess, options = {}) 
      return INVALID_PARAMS_RESULT if current_account.blank? || mess.blank?
      
      result = nil
      
      begin
        account = current_account.is_a?(Account) ? current_account : Account.find(current_account.to_s)
      rescue Exception => e
        return {:status => false, :message => "Invalid account"}
      end
      
      messages = []
      [mess].flatten.each do |m|
        begin
          message = m.is_a?(Message) ? m : Message.find(m.to_s)
          return {:status => false, :message => mess, :text => "Access denied for message #{m.inspect}"} unless account.sent_messages.include?(m) || account.received_messages.include?(m)
          messages << message
        rescue Exception => e
          return {:status => false, :message => mess, :text => "Message #{m.inspect} not found"}
        end
      end
      
      result = nil
      messages.each do |m|
        result = remove_message(account, m)
      end
      result
    end
    
    def self.remove_message(account, message)
      if account.received_messages.include?(message)
        account.received_messages.delete_if {|m| m == message}
        account.save
        return {:status => true, :message => message, :text => "Message removed"}
      elsif account.sent_messages.include?(message)
        account.sent_messages.delete_if {|m| m == message}
        account.save
        receiver = Account.find(message.receiver_id) rescue nil
        receiver.delete_if {|m| m == message}
        receiver.save
        return {:status => true, :message => message, :text => "Message removed"}
      else
        return {:status => false, :message => mess, :text => "Access denied"} 
      end
    end
    
  end
end