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
      "image" => rolable.avatar.respond_to?("exists?") && rolable.avatar.exists? ? rolable.avatar.url : DEFAULT_LOGO, 
      "email" => current_account.email
    }
    session[:current_account] = account    
    account
  end
  
  def logout_current_account
    session.delete(:current_account)
  end
  
  def body_class_for_request
    controller = if params[:controller].start_with?("admin/")
      "admin"
    else
      params[:controller].split("/").join(".")
    end
    [controller, params[:action]].join(" ")
  end
  
  def require_attributes(model)
    model.class._validators.select { |field, field_validators| !field_validators.select { |validator| validator.class.to_s == "Mongoid::Validations::PresenceValidator" }.empty? }.keys 
  end
  
end
