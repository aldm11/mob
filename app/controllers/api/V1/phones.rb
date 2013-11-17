require "sinatra"

module Api
  module V1
    class Phones < Sinatra::Base
      SORT_MAPPINGS = {
        :relevance => {"relevance" => "desc"},
        :date => {"created_at" => "desc"},
        :price => {"price" => "desc"}
      }
      
      before do
        headers "Content-Type" => "text/json"
      end
      
      get "/" do
        browse_phones.to_json
      end
      
      post "/" do
        browse_phones.to_json
      end
      
      def browse_phones
        options = {
          :search_term => params[:search_term] || nil,
          :search_filters => {},
          :search_sort => params[:sort_by] ? SORT_MAPPINGS[params[:sort_by].to_sym] : nil,
          :search_from => params[:from] || 0,
          :search_size => params[:size] || 16
        }
            
        options[:search_filters].merge!("brand" => params[:brand]) if params[:brand] && !params[:brand].empty?
        
        if params[:price_from] && params[:price_to]
          options[:search_filters].merge!("prices" => {"from" => params[:price_from], "to" => params[:price_to]})
          min_price = params[:price_from].to_f
          max_price = params[:price_to].to_f
        end
        
        
        Search::ESSearch.search(options)
        phones = Search::ESSearch.results
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