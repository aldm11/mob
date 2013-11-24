class AccountDecorator < Draper::Base
  decorates :account
 
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