module ApplicationHelper
  def devise_mapping
    Devise.mappings[:account]
  end
  
  DEFAULT_LOGO = "/images/no_image.jpg"
  def current_account_json
    return nil unless account_signed_in?
    return session[:current_account] if session[:current_account]
    
    rolable = current_account.rolable
    account = {
      "account_id" => current_account.id.to_s, 
      "username" => current_account.username, 
      "name" => rolable.name, 
      "image" => rolable.logo.respond_to?("exists?") && rolable.logo.exists? ? rolable.logo.url : DEFAULT_LOGO, 
      "email" => current_account.email
    }
    session[:current_account] = account    
    account
  end
  
  def logout_current_account
    session.delete(:current_account)
  end
  
end
