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

  def to_hash
    res = self.attributes.with_indifferent_access
    res[:logo] = self.logo.to_s
    res
  end
  
  #TODO: remove aliases and try to use alias_method if possible
  ALIASES =  {:avatar => "logo"}
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