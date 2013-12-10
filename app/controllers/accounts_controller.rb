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
  
  def destroy
    
  end
  
  def update
    
  end
  
end