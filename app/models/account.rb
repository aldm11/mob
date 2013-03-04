class Account
  include Mongoid::Document
  include Mongoid::Paperclip
  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :lockable
  
  field :username, :type => String
  
  belongs_to :rolable, polymorphic: true

  has_and_belongs_to_many :following, class_name: 'Account', inverse_of: :followers, autosave: true
  has_and_belongs_to_many :followers, class_name: 'Account', inverse_of: :following
  
  has_and_belongs_to_many :phone_followings, class_name: 'Phone'  
  has_many :comments
  
  validates :username, length: {minimum: 6, maximum: 20}
end
  
