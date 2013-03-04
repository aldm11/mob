class Admin
  include Mongoid::Document
  include Mongoid::Paperclip 

  field :name, :type => String
  field :created_at, :type => DateTime
  field :phone, :type => Array
  
  has_mongoid_attached_file :avatar
  
  has_one :account, as: :rolable
end