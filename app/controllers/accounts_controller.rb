class AccountsController < ApplicationController
  
  DEFAULT_LOGO = "/images/no_image.jpg"
  def accounts_details
    ids = params[:id].flatten
    
    accounts = []
    ids.each do |id|
      acc = Account.find(id)
      rolable = acc.rolable
      accounts << {:id => acc.id.to_s, :username => acc.username, :name => rolable.name, :image => rolable.logo.exists? ? rolable.logo.url : DEFAULT_LOGO, :email => acc.email}
    end
    
    render accounts.to_json
  end
  
  def show
    @account_info = AccountDecorator.decorate(current_account).get_info
  end
  
  FILTER_PROPERTIES = ["authenticity_token", "utf8", "controller", "action", "_method"]
  def remove
    properties_to_remove = params.clone
    properties_to_remove.delete_if { |name, value| FILTER_PROPERTIES.include?(name.to_s) }
    properties_to_remove = Hash[properties_to_remove.map { |name, value| [name.to_s.split("_").first, value] }]
    
    remove_result = Managers::AccountManager.remove(current_account, properties_to_remove)
    if remove_result[:status]
      render :json => {:message => remove_result[:message], :attributes => remove_result[:attributes]}, :status => 200
    else
      render :json => {:message => remove_result[:message]}, :status => 400
    end
    
  end
  
  def add
    properties_to_add = params.clone
    properties_to_add.delete_if { |name, value| FILTER_PROPERTIES.include?(name.to_s) }
    properties_to_add = Hash[properties_to_add.map { |name, value| [name.to_s.split("_").first, value] }]
    
    add_result = Managers::AccountManager.add(current_account, properties_to_add)
    if add_result[:status]
      render :json => {:message => add_result[:message], :attributes => add_result[:attributes]}, :status => 200
    else
      render :json => add_result[:message], :status => 400
    end
  end
  
end