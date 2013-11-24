require "sinatra"

module Api
  module V1
    class Phones < Sinatra::Base
      
      before do
        headers "Content-Type" => "text/json"
      end
      
      get "/browse" do
        browse_phones.map{|phone| PhoneDecorator.decorate(phone).get_metadata}.to_json
      end
      
      post "/browse" do
        browse_phones.map{|phone| PhoneDecorator.decorate(phone).get_metadata}.to_json
      end
      
      get "/" do
        phones = Managers::PhoneManager.get_phones
        phones.to_json
      end
      
      get "/*" do
        phone_id = params[:splat].first
        response = nil
        phone = Phone.find(phone_id) rescue nil       
        halt 400, "Phone not found" unless phone
        halt 400, "only_offers can be specified only if include_offers specified" if params[:only_offers] && !params[:include_offers]
        halt 400, "only_comments can be specified only if include_comments specified" if params[:only_comments] && !params[:include_comments]
        
        phone = PhoneDecorator.decorate(phone)
        options = {}
        options[:include_comments] = params[:include_comments] || nil
        options[:comments_from] = params[:comments_from] ? params[:comments_from].to_i : nil
        options[:comments_to] = params[:comments_to] ? params[:comments_to].to_i : nil
        options[:only_comments] = params[:only_comments] || nil
        options[:include_offers] = params[:include_offers] || nil
        options[:offers_from] = params[:offers_from] ? params[:offers_from].to_i : nil
        options[:offers_to] = params[:offers_to] ? params[:offers_to].to_i : nil
        options[:only_offers] = params[:only_offers] || nil
        
        phone.get_hash(options).to_json
      end
      
      def browse_phones
        options = {
          :search_term => params[:search_term] || nil,
          :search_filters => {},
          :search_sort => params[:sort_by] || nil,
          :search_from => params[:from] || 0,
          :search_size => params[:size] || 16
        }
            
        options[:search_filters].merge!("brand" => params[:brand]) if !params[:brand].blank?
        
        if params[:price_from] && params[:price_to]
          options[:search_filters].merge!("prices" => {"from" => params[:price_from], "to" => params[:price_to]})
          min_price = params[:price_from].to_f
          max_price = params[:price_to].to_f
        end
        
        
        Search::ESSearch.search(options)
        phones = Search::ESSearch.results.results
      end
       
      def params
        env["action_dispatch.request.path_parameters"].merge(super).with_indifferent_access
      end
      
      def path 
        env["PATH_INFO"]
      end
    end
  end
end