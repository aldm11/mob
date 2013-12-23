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
  
  def change_password
    if current_account.valid_password?(params[:old_password])
      if current_account.reset_password!(params[:new_password], params[:password_confirmation])
        current_account.save
        sign_in(current_account, :bypass => true)
        render :json => {:message => "Password changed sucesfully"}, :status => 200
      else
        render :json => "Invalid new password. Password must be at least 6 characters long. Password must match confirmation.", :status => 400
      end
    else
      render :json => "Wrong password", :status => 400
    end
  end
  
  def change_avatar
    current_account.rolable.avatar = params[:avatar]
    if current_account.save && current_account.rolable.save
      current_account.reload
      render :json => "success"
    else
      render :json => "failure"
    end
  end
  
end