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
        render :json => {:message => "Sifra promijenjena"}, :status => 200
      else
        render :json => "Neispravan format sifre. Sifra mora imati bar 6 znakova. Potvrda sifre se mora poklapati sa sifrom", :status => 400
      end
    else
      render :json => "Pogresna sifra", :status => 400
    end
  end
  
  ALLOWED_AVATAR_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif"]
  MAX_AVATAR_SIZE = 4000000
  def change_avatar
    if(params[:avatar].size > MAX_AVATAR_SIZE)
      render :json => I18n.t("accounts.file_too_big_error", max_size: MAX_AVATAR_SIZE/1000000), :status => 400
      return
    end
    
    file_extension = File.extname(params[:avatar].original_filename).strip.downcase
    unless ALLOWED_AVATAR_EXTENSIONS.include?(file_extension)
      render :json => I18n.t("accounts.file_bad_extension_error", allowed_extensions: ALLOWED_AVATAR_EXTENSIONS.join(", ")), :status => 400
      return
    end
    
    current_account.rolable.avatar = params[:avatar]
    if current_account.save && current_account.rolable.save
      current_account.reload
      render :json => {:status => "success", :avatar => AccountDecorator.decorate(current_account).get_avatar }, :status => 200
    else
      render :json => I18n.t("accounts.change_avatar_error"), :status => 400
    end
  end
  
end