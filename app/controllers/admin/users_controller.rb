class Admin::UsersController < ApplicationController
  
  before_filter :admin_only
  layout "admin"
  
  def list_users
    @users = Managers::UserManager.get_all_users
  end
  
  def lock_user
    account = User.find(params[:id]).account
    account.lock_access!
    
    redirect_to :action => "list_users"
  end
  
  private
  def admin_only
    redirect_to(:controller => "home", :action => "index") unless account_signed_in? && current_account.rolable.class.name.downcase == "admin"
  end
  
end
