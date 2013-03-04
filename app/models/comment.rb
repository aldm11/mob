class Comment
  include Mongoid::Document
  include Mongoid::Paperclip
    
  field :text, :type => String
  field :created_at, :type => DateTime
  field :active, :type => Boolean
  
  belongs_to :context, polymorphic: true
  belongs_to :account
  
  attr_accessible :text, :created_at, :active
  
  before_save do |comment|
    comment.created_at = Time.new.to_time.to_i
    comment.active = true
  end
end