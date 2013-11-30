module Api
  module V1
    class Phones < Base    
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
        halt 400, "only_offers can be specified only if include_offers specified" if parameters[:only_offers] && !parameters[:include_offers]
        halt 400, "only_comments can be specified only if include_comments specified" if parameters[:only_comments] && !parameters[:include_comments]
        
        phone = PhoneDecorator.decorate(phone)
        options = {}
        
        options[:include_comments] = parameters[:include_comments] || nil
        options[:comments_from] = parameters[:comments_from] ? parameters[:comments_from].to_i : nil
        options[:comments_to] = parameters[:comments_to] ? parameters[:comments_to].to_i : nil
        options[:only_comments] = parameters[:only_comments] || nil
        options[:include_offers] = parameters[:include_offers] || nil
        options[:offers_from] = parameters[:offers_from] ? parameters[:offers_from].to_i : nil
        options[:offers_to] = parameters[:offers_to] ? parameters[:offers_to].to_i : nil
        options[:only_offers] = parameters[:only_offers] || nil
        
        phone.get_hash(options).to_json
      end
      
      private
      def browse_phones
        options = {
          :search_term => parameters[:search_term] || nil,
          :search_filters => {},
          :search_sort => parameters[:sort_by] || nil,
          :search_from => parameters[:from] || 0,
          :search_size => parameters[:size] || 16
        }
            
        options[:search_filters].merge!("brand" => parameters[:brand]) if !parameters[:brand].blank?
        
        if parameters[:price_from] && parameters[:price_to]
          options[:search_filters].merge!("prices" => {"from" => parameters[:price_from], "to" => parameters[:price_to]})
          min_price = parameters[:price_from].to_f
          max_price = parameters[:price_to].to_f
        end
        
        
        Search::ESSearch.search(options)
        phones = Search::ESSearch.results.results
      end
       
    end
  end
end