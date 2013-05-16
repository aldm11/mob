class Admin::PhonesController < ApplicationController
  layout "admin"
  
  include Importers::Database::PhoneImporter
  before_filter :admin_only
  
  def new
    @phone  = Phone.new
  end
  
  def create
    params[:phone].merge!({:account_id => current_account.id})
    result = Managers::PhoneManager.add_phone(params[:phone])
    if result[:status]
      flash[:success] = I18n.t(:phone_added)
    else
      flash[:error] = result[:message]+" "+result[:phone].errors.full_messages.join(" ")
    end
    redirect_to :action => "new"
  end
  
  def list_phones
    @phones = Managers::PhoneManager.get_phones
  end
  
  def add_attribute
    result = Managers::PhoneManager.add_phone_attribute(params)
    
    if result[:status]
      flash[:success] = result[:message]
    else
      flash[:error] = result[:message]
    end
    
    redirect_to :action => "attributes"
  end
  
  def attributes
    @attribute_fields = Managers::PhoneManager.attribute_fields
    @attributes = Managers::PhoneManager.get_all_attributes
  end
  
  def import_phones
    @brands = DataStore::Memory::PhoneDetails.get_brands
  end
  
  def import
    begin
      import_phones_from_json(:brand => params[:brand])
      flash[:success] = "Brand #{params[:brand]} imported"
    rescue Exception => e
      flash[:error]= e.message
    end
    redirect_to :action => "import_phones"
  end
  
  def import_images
    begin
      import_phones_images_from_json(:brand => params[:brand])
      flash[:success] = "Brand #{params[:brand]} images imported"
    rescue Exception=> e
      flash[:error] = e.message
    end
    redirect_to :action => "import_phones"
  end
  
end
