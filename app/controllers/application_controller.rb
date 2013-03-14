require "mongoid"

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale, :setup
  
  include SessionHelper
  include CollectionHelper
  include AccountHelper
    
  def unathorized_access
    respond_to do |format|
      format.js
    end
  end
  
  protected
  def only_signed_in_users
    redirect_to(:action => "unathorized_access") unless account_signed_in?
  end
  
  def admin_only
    redirect_to(:action => "unathorized_access") unless account_signed_in? && current_account.rolable.class.name.downcase == "admin"
  end
  
  private
  def set_locale
    I18n.locale = "en"
  end
  
  def setup
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
  
  
end
