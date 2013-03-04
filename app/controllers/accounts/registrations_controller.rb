class Accounts::RegistrationsController < Devise::RegistrationsController
  
  def index
    
  end
  
  def create
    build_resource
    params[params[:account][:type].to_sym][:phone] = params[params[:account][:type].to_sym][:phone] ? [params[params[:account][:type].to_sym][:phone]] : []
    rolable = params[:account][:type].downcase.camelize.constantize.new(params[params[:account][:type].to_sym])
    resource.rolable = rolable
    resource.username = form_username(resource.email) if resource.email
    
    valid = rolable.valid? && resource.valid?
    
    rolable.errors.messages.each do |attribute, message|
      unless attribute == :account
        hsh = {}
        hsh[attribute] = message
        resource.errors.messages.merge!(hsh)
      end
    end

    if valid && resource.save && resource.rolable.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      puts "iz else #{resource.errors.full_messages}"
      respond_with resource
    end
  end
  
  def new
    super
  end
  
end