class Admin
  include Mongoid::Document
  include Mongoid::Paperclip 

  field :name, :type => String
  field :created_at, :type => DateTime
  field :phone, :type => Array
  
  has_mongoid_attached_file :avatar
  
  has_one :account, as: :rolable
  
  # hack for chat, so admin can chat also
  def logo
    "/images/no_image.jpg"
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