module ApplicationHelper
  def devise_mapping
    Devise.mappings[:account]
  end
  
  DEFAULT_LOGO = "/images/no_image.jpg"
  def current_account_json
    rolable = current_account.rolable
    account = {
      "account_id" => current_account.id.to_s, 
      "username" => current_account.username, 
      "name" => rolable.name, 
      "image" => rolable.logo.respond_to?("exists?") && rolable.logo.exists? ? rolable.logo.url : DEFAULT_LOGO, 
      "email" => current_account.email
    }
    account
  end
  
end
