class CommentDecorator < Draper::Base
  decorates :comment
  
  FILTER_ATTRIBUTES = [:_id, :_type, :account_id, :context_id, :context_type, :active]
  def get_hash(options = {})
    comment_hash = comment.to_hash.with_indifferent_access
    provider = Account.find(comment_hash[:account_id])
    provider = AccountDecorator.decorate(provider)
    comment_hash[:provider] = provider.get_hash({:context => "comment"})
    
    comment_hash.delete_if { |attr, val| FILTER_ATTRIBUTES.include?(attr.to_sym) }    
    comment_hash
  end    
end