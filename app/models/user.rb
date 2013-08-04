class User
  include Mongoid::Document
  include Mongoid::Paperclip
    
  field :name, :type => String
  field :address, :type => String
  field :phone, :type => Array #[{type, number}] type optional

  field :created_at, :type => DateTime #check if exists by default in mongo or in devise
  field :followers, :type => Array #[{name, id, type}]
  field :followings, :type => Array #: [{name, id, type}]
  
  has_mongoid_attached_file :avatar
  
  validates :name, :presence => true
  #TODO: validate phone format
  
  attr_accessible :name, :address, :phone

  has_one :account, as: :rolable
  has_many :catalogue_items, as: :provider
  
  before_save do |user|
    user.created_at = Time.now
  end
  
  ALIASES =  {:avatar => "logo"}
  EMPTY = [:website]
  def method_missing(method_name, *args, &block)
    if defined?(ALIASES) && ALIASES.keys.map {|k| k.to_s}.include?(method_name.to_s)
      self.send(ALIASES[method_name.to_sym])
    elsif defined?(EMPTY) && EMPTY.include?(method_name)
      nil
    else
      super
    end  
  end
end