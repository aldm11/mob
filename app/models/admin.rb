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
  
  def to_hash
    attr_names = self.fields.keys    
    res = Hash[attr_names.map { |attr| [attr, self.attributes[attr]] }].with_indifferent_access
    res[:avatar] = self.avatar.to_s
    res
  end
end