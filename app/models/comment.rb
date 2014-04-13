class Comment
  include Mongoid::Document
  include Mongoid::Paperclip
    
  field :text, :type => String
  field :created_at, :type => DateTime
  field :active, :type => Boolean
  
  belongs_to :context, polymorphic: true
  belongs_to :account
  
  attr_accessible :text, :created_at, :active
  
  def to_hash
    res = self.attributes.with_indifferent_access
    res
  end
  
  before_save do |comment|
    comment.created_at = Time.new.utc.to_i
    comment.active = true
  end
end