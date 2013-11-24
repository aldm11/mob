class MessageDecorator < Draper::Base
  decorates :message
  
  FILTER_ATTRIBUTES = [:mark_deleted, :auto_generated, :context, :sender_id, :receiver_id]
  def get_hash(options = {})
    message_hash = message.to_hash.with_indifferent_access
    
    message_hash.delete_if {|attr, val| FILTER_ATTRIBUTES.include?(attr.to_sym) }
    message_hash
  end
end