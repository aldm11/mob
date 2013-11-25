require "sinatra"

module Api
  module V1
    class Catalogue < Sinatra::Base
      
      get "/*" do
        identificator = params[:splat].first
        account = BSON::ObjectId.legal?(identificator) ? Account.find(identificator) : Account.where(username: identificator).to_a       
        
        if account.blank?
          auth_header = env["HTTP_AUTHORIZATION"]
          if auth_header && auth_header.start_with?("Basic")
            email, password = auth_header.sub("Basic ", "").split(":")
            account = Account.find_for_database_authentication(:email => email)
            account = nil unless account && account.valid_password?(password)
          elsif auth_header && auth_header.start_with?("Cookie") && env["warden"].authenticated?
            account = env["warden"].user
          end
        end
        
        halt 400, "invalid account" if account.blank?
        
        account = account.first if account.is_a?(Array)

        catalogue_items = Managers::CatalogueManager.get_catalogue(account)
        catalogue_items.map! { |catalogue_item| CatalogueItemDecorator.decorate(catalogue_item).get_hash }
        catalogue_items.to_json
      end
      
      post "/" do
        
      end
      
      delete "/" do
        
      end
      
      
    end
  end
end