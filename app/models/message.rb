class Message
  include Mongoid::Document
  include Mongoid::Paperclip
  
  include Comparable
  
  field :text, :type => String
  field :date_sent, :type => DateTime 
  field :date_read, :type => DateTime 
  field :auto_generated, :type => Boolean
  field :context, :type => Hash # not used for now
  field :sender_id, :type => String
  field :receiver_id, :type => String
  field :mark_deleted, :type => Boolean, :default => false
  
  field :sender_details, :type => Hash
  field :receiver_details, :type => Hash
  
  field :reply_to, :type => String
  field :reply_to_type, :type => String
  field :responded_with, :type => String 
  field :responded_with_type, :type => String
  
  embedded_in :sender, class_name: "Account", inverse_of: :sent_messages
  embedded_in :receiver, class_name: "Account", inverse_of: :received_messages
  
  #TODO: attachments stored as Moped::BSON::Binary as byte array with limit in size
  
  validates :text, :presence => true, length: {minimum: 10}
  validates :sender_id, :presence => true
  validates :receiver_id, :presence => true
  
  SUBJECT_ATTRS = ["id", "avatar", "name", "website", "phone", "address"]
  DEFAULT_LOGO = "/images/no_image.jpg"
  before_create do |message|
    message.date_sent = Time.now.utc.to_time.to_i unless message.date_sent
    
    ### Setting source and target attributes
    puts "Setting source and target"
    
    sen_acc = Account.find(self.sender_id)
    sen = sen_acc.rolable
    sen_rec = Account.find(self.receiver_id)
    rec = sen_rec.rolable
    
    self.sender_details = {"username" => sen_acc.username}
    self.receiver_details = {"username" => sen_rec.username}
    SUBJECT_ATTRS.each do |attr|
      if sen.respond_to?(attr)      
        if attr == "avatar"
          val_sen = sen.avatar.exists? ? sen.avatar.url : DEFAULT_LOGO
        else
          val_sen = sen.send(attr)
        end
        self.sender_details[attr] = val_sen
      end
      
      if rec.respond_to?(attr) 
        if attr == "avatar"
          val_rec = rec.avatar.exists? ? rec.avatar.url : DEFAULT_LOGO
          puts "receiver logo #{val_rec.inspect}"
        else
          val_rec = rec.send(attr)
        end
        self.receiver_details[attr] = val_rec
      end
    end
  end
  
  before_save do |message|
    message.date_sent = message.date_sent.to_time.utc.to_i if message.date_sent
    message.date_read = message.date_read.to_time.utc.to_i if message.date_read
  end
  
  def sort_unread(other)
    return 1 if self.date_read.nil? && !other.date_read.nil?
    return -1 if !self.date_read.nil? && other.date_read.nil?
    0
  end
  
  def to_hash
    res = self.attributes.with_indifferent_access
    res
  end
end