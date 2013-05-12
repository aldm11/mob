class CataloguesController < ApplicationController
  before_filter :only_signed_in_users, :only => [:new, :create, :pre_remove, :remove, :edit, :update]
  
  #TODO: implement button to see changes for this phone in another suppliers if it's my own and another's catalogue
  
  
  def new
    @phones_names = Phone.asc(:brand).map {|phone| phone.name }
    respond_to { |format| format.js }
  end
  
  def index
    username = params[:username]
    account = account_signed_in? ? current_account : Account.where(username: username)
    @my_item = account_signed_in? && current_account.username == params[:username]
    @catalogue_items = Managers::CatalogueManager.get_catalogue(account)
    @catalogue_phones = Catalogue.new(account, @catalogue_items).full_items
  end
  
  def pre_remove
    respond_to { |format| format.js }
  end
  
  def remove
    Managers::CatalogueManager.remove_phone(current_account, params[:phone_id]) if account_signed_in?
    respond_to { |format| format.js }
  end
  
  def edit
    respond_to { |format| format.js }
  end
  
  def update
    phone = params[:phone_name]
    price = params[:price]
    result = Managers::CatalogueManager.add_phone(current_account, phone, price)   
    result[:status] ? flash[:success] = result[:message] : flash[:error] = result[:message]
    @catalogue_phone = Catalogue.new(current_account, result[:catalogue_item]).full_items.first    
    respond_to { |format| format.js }
  end
  
  def phone_details
    @phone = PhoneDecorator.decorate(Phone.asc(:brand).to_a.select { |phone| phone.name == params[:phone_name] }.first)
  end
  
end