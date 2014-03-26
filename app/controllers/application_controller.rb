require "mongoid"

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale, :setup, :search_setup, :js_vars
  
  include ApplicationHelper
  include SessionHelper
  include CollectionHelper
  include AccountHelper
        
  def unauthorized_access
    respond_to do |format|
      format.js
    end
  end
  
  def show_error
  end
  
  def set_js_vars
    params[:vars].each do |name, value|
      @@js_vars[name.to_sym] = value unless name.nil? || value.nil?
    end
    render :json => @@js_vars.select {|name, value| params[:vars].has_key?(name.to_s) }.to_json
  end
  
  def get_js_var
    var = @@js_vars[params[:name].to_sym] || nil
    render :json => var.to_json
  end
  
  protected
  def only_signed_in_users
    redirect_to(:controller => "application", :action => "unauthorized_access") unless account_signed_in?
  end
  
  def admin_only
    redirect_to(:action => "unauthorized_access") unless account_signed_in? && current_account.rolable.class.name.downcase == "admin"
  end
  
  def js_vars
    @@js_vars ||= {}
  end
  
  private
  def set_locale
    I18n.locale = "bs"
  end
  
  def search_setup
  end
  
  def setup
    # only when user logged in
    check_and_set_username   
  end
  
  def check_and_set_username
    if account_signed_in? && current_account.username.nil?
      username = form_username(current_account.email)
      current_account.update_attributes(username: username)
      if current_account.save
        logger.info "Username saved for account #{account.inspect}"
      else
        logger.info "Error while setting username #{current_account.errors.full_messages.join(" ")}"
      end
    end 
  end
  
  def after_sign_in_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    home_path = "#{scope}_phones_path"
    respond_to?(home_path, true) ? send(home_path) : phones_path
  end
  
  def after_sign_out_path_for(resource_or_scope)
    URI(request.referer).path == "/" ? root_path : phones_path
  end
end
