require "sinatra"
require "rack/csrf"

module Api
  module V1
    
    class Base < Sinatra::Base
      @account = nil
      @parameters = {}
      
      configure do
        use Rack::Session::Cookie, :secret => "56352b45b7dffb174b52338e6f780439cda6d42bb20b70371ead8a04da4be5126600d0c610a5a186503320ba901a9eec4bce9d797508b953819c60173dc69e51"
        use Rack::Csrf, :skip_if => lambda { |request|
          request.env["CONTENT_TYPE"].include?("application/json")
        }
      end
      
      before do
        headers "Content-Type"=> "text/json"
        get_params
        authenticate_user       
      end
      
      def parameters
        @parameters
      end
      
      def authenticate_user        
        auth_header = env["HTTP_AUTHORIZATION"]
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
        body = body.blank? ? {} : JSON.parse(body)
        result = request.env['rack.request.query_hash']
        result.merge!(body)
        result = result.with_indifferent_access
        
        @parameters = result
      end
      
      def path 
        env["PATH_INFO"]
      end
      
      def require_authorization
        halt 401, "Unauthorized client" unless @account 
      end
      
    end
    
  end
end
