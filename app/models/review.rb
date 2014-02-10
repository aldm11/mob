class Review
  include Mongoid::Document
  include Mongoid::Paperclip
   
  field :like, :type => Boolean 
  field :updated, :type => DateTime
  field :account_id, :type => String
  
  #field :review, :type => Integer
  #field :active, :type => Boolean
  #field :created_at, :type => DateTime
  
  embedded_in :phone
  
  attr_accessible :review, :updated, :account_id
  
  before_save do |review|
    review.updated = Time.new.to_time.to_i
    # review.created_at = Time.new.to_time.to_i
  end
end