class Store
  include Mongoid::Document
  include Mongoid::Paperclip
      
  field :name, :type => String
  field :address, :type => Array #{ street, city }
  field :phone, :type => Array #[{type, number}] type optional
  field :fax, :type => Array
  field :website, :type => Array
  
  field :created_at, :type => DateTime #check if exists by default in mongo or in devise
  field :followers, :type => Array # [{name, id, type}]
  field :followings, :type => Array #[{name, id, type}]
    
  validates :name, :presence => true
  
  has_mongoid_attached_file :logo
  
  attr_accessible :name, :address, :phone, :fax, :website

  has_one :account, as: :rolable
  has_many :catalogue_items, as: :provider

  def to_hash
    res = self.attributes.with_indifferent_access
    res[:avatar] = self.avatar.to_s
    res
  end
  
  ALIASES =  {"avatar" => "logo", "avatar=" => "logo="}
  ALIASES.each do |ali, orig|
    alias_method(ali.to_sym, orig.to_sym)
  end  

end