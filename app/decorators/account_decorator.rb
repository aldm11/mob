class AccountDecorator < Draper::Base
  decorates :account
 
  DISPLAY_ACCOUNT_INFO = ["name", "phone", "address", "fax", "website"]
  DEFAULT_AVATAR = "/images/no_image.jpg"
  def get_info(options = {})
    result = {
      :email => {:value => account.email, :display => true, :label => I18n.t("mongoid.attributes.account.email")}, 
      :username => {:value => username, :display => true, :label => I18n.t("mongoid.attributes.account.username")}
    }
    rolable_type = account.rolable._type.downcase
    rolable_hash = Hash[get_hash.map do |attr, val| 
      label = I18n.t(["mongoid", "attributes", rolable_type, attr.to_s].join("."))
      display = DISPLAY_ACCOUNT_INFO.include?(attr.to_s)
      [attr, {:value => val, :display => display, :label => label}]
    end] 
    rolable_hash[:avatar] = {:value => get_avatar}
    result.merge!(rolable_hash)
    result = result.with_indifferent_access
    result
  end
  
  def get_avatar
    account.rolable.avatar.exists? ? account.rolable.avatar : DEFAULT_AVATAR
  end
 
  FILTER_ATTRIBUTES = [:followings, :followers]
  def get_hash(options = {})
    acc_rolable = account.rolable.to_hash.with_indifferent_access

    filter_attrs = FILTER_ATTRIBUTES
    if options[:context] == "comment"
      filter_attrs << [:address, :phone, :fax, :website]
      filter_attrs.flatten!
    end
    acc_rolable.delete_if { |attr, val| filter_attrs.include?(attr.to_sym) }
    
    acc_rolable
  end
end