module Api
  module V1
    class Catalogue < Base
      
      get "/*" do
        identificator = params[:splat].first
        if BSON::ObjectId.legal?(identificator)
          account = Account.find(identificator) rescue nil
        else
          account = Account.where(username: identificator).to_a
        end   
        
        account = @account if account.blank? && !@account.nil?
        
        halt 400, "Invalid account" if account.blank?
        
        account = account.first if account.is_a?(Array)

        catalogue_items = Managers::CatalogueManager.get_catalogue(account)
        catalogue_items.map! { |catalogue_item| CatalogueItemDecorator.decorate(catalogue_item).get_hash(:context => "catalogue") }
        response = { :catalogue_items => catalogue_items, :provider => AccountDecorator.decorate(account).get_hash }
        response.to_json
      end
      
      post "/" do        
        require_authorization
        
        phone = parameters[:phone_name]
        price = parameters[:price]
                
        halt 400, "Must provide phone name and price" unless phone && price
        halt 400, "Price must be numeric value" unless price.is_a?(Fixnum) || price.is_a?(Float) #price.match(/^([1-9][0-9]{,2}(,[0-9]{3})*|[0-9]+)(\.[0-9]{1,9})?$/).nil?
        
        result = Managers::CatalogueManager.add_phone(@account, phone, price)
        
        halt 400, result[:message] unless result[:status]
        
        CatalogueItemDecorator.decorate(result[:catalogue_item]).get_hash(:context => "catalogue").to_json
      end
      
      delete "/*" do
        require_authorization
  
        phone_id = params[:splat].first
        halt 400, "phone_id not provided" unless phone_id

        result = Managers::CatalogueManager.remove_phone(@account, phone_id)
        halt 400, result[:message] unless result[:status]
        
        CatalogueItemDecorator.decorate(result[:catalogue_item]).get_hash(:context => "catalogue").to_json
      end
      
    end
  end
end