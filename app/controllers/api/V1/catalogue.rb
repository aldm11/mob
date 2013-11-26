require "sinatra"

module Api
  module V1
    class Catalogue < Sinatra::Base
      before do
        headers "Content-Type"=> "text/json"
        authenticate_user
      end
      
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
        halt 401, "Unauthorized client" unless @account
        
        phone = get_params[:phone_name]
        price = get_params[:price]
                
        halt 400, "Must provide phone name and price" unless phone && price
        halt 400, "Price must be numeric value" unless price.is_a?(Fixnum) || price.is_a?(Float) #price.match(/^([1-9][0-9]{,2}(,[0-9]{3})*|[0-9]+)(\.[0-9]{1,9})?$/).nil?
        
        result = Managers::CatalogueManager.add_phone(@account, phone, price)
        
        halt 400, result[:message] unless result[:status]
        
        CatalogueItemDecorator.decorate(result[:catalogue_item]).get_hash(:context => "catalogue").to_json
      end
      
      delete "/" do
        halt 401, "Unauthorized client" unless @account
  
        phone_id = get_params[:phone_id]
        halt 400, "phone_id not provided" unless phone_id

        result = Managers::CatalogueManager.remove_phone(@account, phone_id)
        halt 400, result[:message] unless result[:status]
        
        CatalogueItemDecorator.decorate(result[:catalogue_item]).get_hash(:context => "catalogue").to_json
      end
      
      
      def authenticate_user        
        auth_header = env["HTTP_AUTHORIZATION"]
        puts "evo #{env["warden"].authenticated?.inspect} --- #{env["warden"].user.inspect}"
        @account = nil
        if auth_header && auth_header.start_with?("Basic")
          email, password = auth_header.sub("Basic ", "").split(":")
          @account = Account.find_for_database_authentication(:email => email)
          @account = nil unless @account && @account.valid_password?(password)
        elsif auth_header && auth_header.start_with?("Cookie") && env["warden"].authenticated?
          @account = env["warden"].user
        end
      end
      
      def get_params
        request.body.rewind
        body = request.body.read
        body = body.blank? ? nil : JSON.parse(body)
        result = env["action_dispatch.request.path_parameters"]
        result.merge!(body) if body
        result.with_indifferent_access
      end
      
      def path 
        env["PATH_INFO"]
      end
      
    end
  end
end