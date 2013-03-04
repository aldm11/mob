class Store
  include Mongoid::Document
  include Mongoid::Paperclip
    
  field :name, :type => String
  field :address, :type => Hash #{ street, city }
  field :phone, :type => Array #[{type, number}] type optional
  field :fax, :type => Array
  field :website, :type => String
  
  field :created_at, :type => DateTime #check if exists by default in mongo or in devise
  field :followers, :type => Array # [{name, id, type}]
  field :followings, :type => Array #[{name, id, type}]
  
  validates :name, :presence => true
  
  has_mongoid_attached_file :logo
  
  attr_accessible :name, :address, :phone, :fax, :website

  has_one :account, as: :rolable
  has_many :catalogue_items, as: :provider
end