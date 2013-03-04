class Review
  include Mongoid::Document
  include Mongoid::Paperclip
    
  field :review, :type => Integer
  field :created_at, :type => DateTime
  field :active, :type => Boolean
  field :account_id, :type => String
  
  embedded_in :phone
  
  attr_accessible :review, :created_at, :active, :account_id
  
  before_save do |review|
    review.created_at = Time.new.to_time.to_i
  end
end