class Review
  include Mongoid::Document
  include Mongoid::Paperclip
   
  field :like, :type => Boolean 
  field :updated, :type => DateTime
  field :account_id, :type => String
  field :history, :type => Array
  
  embedded_in :phone
  
  attr_accessible :like, :updated, :account_id
  
  before_save do |review|
    review.updated = Time.new.to_time.to_i
    review.history = [] if review.history.nil?
    review.history << { :like => like, :added => updated.to_time.to_i }
    puts "==== prije save review"
  end
end