class Message
  include Mongoid::Document
  include Mongoid::Paperclip
  
  field :text, :type => String
  field :date_sent, :type => DateTime 
  field :date_read, :type => DateTime 
  field :auto_generated, :type => Boolean
  field :context, :type => Hash # not used for now
  field :sender_id, :type => String
  field :receiver_id, :type => String
  field :mark_deleted, :type => Boolean, :default => false
  
  embedded_in :sender, class_name: "Account", inverse_of: :sent_messages
  embedded_in :receiver, class_name: "Account", inverse_of: :received_messages
  
  #TODO: attachments stored as Moped::BSON::Binary as byte array with limit in size
  
  validates :text, :presence => true, length: {minimum: 10}
  validates :sender_id, :presence => true
  validates :receiver_id, :presence => true
  
  before_create do |message|
    message.date_sent = Time.now.utc.to_time.to_i unless message.date_sent
  end
  
  before_save do |message|
    message.date_sent = message.date_sent.to_time.utc.to_i
    message.date_read = message.date_read.to_time.utc.to_i if message.date_read
  end
end