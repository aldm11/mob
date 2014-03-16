class Admin::PhonesController < ApplicationController
  layout "admin"
  
  include Importers::Database::PhoneImporter
  before_filter :admin_only
  
  def new
    @phone  = Phone.new
  end
  
  def create
    phone_params = params[:phone]
    phone_params[:account_id] = current_account.id
    phone_params[:camera] = params[:camera]
    phone_params[:camera]["blic"] = phone_params[:camera]["blic"].to_s == "1" ? true : false if phone_params[:camera]["blic"]
    phone_params[:camera]["front"] = phone_params[:camera]["front"].to_s == "1" ? true : false if phone_params[:camera]["front"]
    phone_params[:camera]["video"] = phone_params[:camera]["video"].to_s == "1" ? true : false if phone_params[:camera]["video"]
    result = Managers::PhoneManager.add_phone(phone_params)
    
    result[:status] ? flash[:success] = result[:message] : flash[:error] = result[:message]    
    redirect_to :action => "new"
  end
  
  def update
    phone_params = params[:phone]
    phone_params[:account_id] = current_account.id
    phone_params[:camera] = params[:camera]
    phone_params[:camera]["blic"] = phone_params[:camera]["blic"].to_s == "1" ? true : false if phone_params[:camera]["blic"]
    phone_params[:camera]["front"] = phone_params[:camera]["front"].to_s == "1" ? true : false if phone_params[:camera]["front"]
    phone_params[:camera]["video"] = phone_params[:camera]["video"].to_s == "1" ? true : false if phone_params[:camera]["video"]
    result = Managers::PhoneManager.add_phone(phone_params)
    
    result[:status] ? flash[:success] = result[:message] : flash[:error] = result[:message]
    redirect_to :action => "edit"
  end
  
  def edit
    @phone = Phone.find(params[:id])
    @phone_dec = PhoneDecorator.decorate(@phone)
    render "new"
  end
  
  def list_phones
    @phones = Managers::PhoneManager.get_phones
  end
  
  def destroy
    id = params[:id]
    @phone = Phone.find(id)
    
    @error = nil
    if @phone
      active_catalogue_items = @phone.catalogue_items.where(:deleted_date => nil).to_a
      if active_catalogue_items.empty?
        @phone.deleted = true
        
        @message = @phone.save ? I18n.t("phones.phone_deleted") : I18n.t("phones.internal.phone_invalid")
      else
        @error = I18n.t("phones.internal.phone_exists_in_catalogue")
      end
    else
      @error = I18n.t("phones.internal.phone_not_exists")
    end
        
    respond_to { |format| format.js }
  end
  
  def add
    id = params[:id]
    @phone = Phone.find(id)
    
    @error = nil
    if @phone
      if @phone.catalogue_items.empty?
        @phone.deleted = false
        @phone.save
        
        @message = I18n.t("phones.phone_undeleted")
      else
        @error = I18n.t("phones.internal.phone_exists_in_catalogue")
      end
    else
      @error = I18n.t("phones.internal.phone_not_exists")
    end
    
    respond_to { |format| format.js }  
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
    #begin
      import_phones_from_json(:brand => params[:brand])
      flash[:success] = "Brand #{params[:brand]} imported"
    #rescue Exception => e
      #flash[:error]= e.message
    #end
    redirect_to :action => "import_phones"
  end
  
  def import_images
    #begin
      import_phones_images_from_json(:brand => params[:brand])
      flash[:success] = "Brand #{params[:brand]} images imported"
    # rescue Exception=> e
      # flash[:error] = e.message
    # end
    redirect_to :action => "import_phones"
  end
  
  def reindex
    Phone.reindex_all    
    flash[:success] = "Mobiteli uspjesno reindeksirani"
    
    redirect_to :action => "list_phones"
  end
  
end
