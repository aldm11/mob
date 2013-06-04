class CataloguesController < ApplicationController
  before_filter :only_signed_in_users, :only => [:new, :create, :pre_remove, :remove, :edit, :update, :phone_details_remote]
  #TODO: implement button to see changes for this phone in another suppliers if it's my own and another's catalogue
    
  def new
    @phones_names = Phone.asc(:brand).map {|phone| phone.name }
    respond_to { |format| format.js }
  end
  
  def index
    username = params[:username]
    account = Account.where(username: username).to_a.first
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
    @result = Managers::CatalogueManager.add_phone(current_account, phone, price)   
    @catalogue_phone = Catalogue.new(current_account, @result[:catalogue_item]).full_items.first    
    respond_to { |format| format.js }
  end
  
  def phone_details_remote
    @phone = PhoneDecorator.decorate(Phone.asc(:brand).to_a.select { |phone| phone.name == params[:phone_name] }.first)
  end
  
  def show_next_page
    from = params[:from].to_i || 0
    size = params[:size].to_i || 10
    
    @to = from + size - 1
    
    offers_details = Managers::PhoneManager.get_offers(params[:phone_id], {:from => from, :to => @to, :sort_by => "date"})
    @all_offers = offers_details[:all_offers]
    @offers = offers_details[:related_offers]
    @to = offers_details[:to]
  end
  
end