require "sinatra"

module Api
  module V1
    class Phones < Sinatra::Base
      
      before do
        headers "Content-Type" => "text/json"
      end
      
      get "/browse" do
        browse_phones.map{|phone| prepare_phone_metadata(phone.to_hash)}.to_json
      end
      
      post "/browse" do
        browse_phones.map{|phone| prepare_phone_metadata(phone.to_hash)}.to_json
      end
      
      get "/" do
        phones = Managers::PhoneManager.get_phones
        phones.to_json
      end
      
      get "/*" do
        phone_id = params[:splat].first
        response = nil
        if phone = Phone.find(phone_id)
          response = phone.to_hash.with_indifferent_access
          unless phone.catalogue_items.empty?
            if params[:offers_from]
              offers_details = Managers::PhoneManager.get_offers(phone, {:from => params[:offers_from].to_i, :to => params[:offers_to].to_i, :sort_by => "date"})
              offers = offers_details[:related_offers]
              min_price = offers_details[:min_price]
              max_price = offers_details[:max_price]
              response[:offers] = offers.map {|offer| offer.to_hash}
              response[:min_price] = min_price
              response[:max_price] = max_price
            end
          end
          
          if(params[:comments_from])
            comments_details = Managers::PhoneManager.get_comments(phone, {:from => params[:comments_from].to_i, :to => params[:comments_to].to_i, :sort_by => "date"})
            comments = comments_details[:related_comments]
            response[:comments] = comments.map{|comment| comment.to_hash}
          end
        end
        phone = prepare_phone(response)
        phone.to_json 
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
      
      def prepare_phone_metadata(orig_phone)        
        phone_hash = orig_phone.clone
        
        prices = phone_hash[:catalogue_items].map{|ci| ci.actual_price}.sort
        phone_hash[:min_price] = prices.first
        phone_hash[:max_price] = prices.last
        
        filter_phone_metadata = [:catalogue_items, :price, :latest_prices_size, :_type, :_index, :_version, :highlight, :_explanation]
        phone_hash.delete_if{ |attr, val| filter_phone_metadata.include?(attr.to_sym) }
                
        phone_hash
      end
      
      def prepare_phone(orig_phone)
        phone_hash = orig_phone.clone.with_indifferent_access
        
        filter_phone = [:_id, :account_id, :comments_count, :image_content_type, :image_file_size, :image_updated_at,
          :latest_price, :latest_prices, :latest_prices_size, :reviews,
          :amazon_image_medium_full_content_type, :amazon_image_medium_full_file_name, :amazon_image_medium_full_file_size, :amazon_image_medium_full_updated_at, 
          :amazon_image_small_full_content_type, :amazon_image_small_full_file_name, :amazon_image_small_full_file_size, :amazon_image_small_full_updated_at
        ]
        phone_hash.delete_if { |attr, val| filter_phone.include?(attr.to_sym) }
        phone_hash[:offers].map! { |offer| prepare_offer(offer) } if phone_hash[:offers]
        phone_hash[:comments].map! {|comment| prepare_comment(comment)} if phone_hash[:comments]
        phone_hash
      end
      
      def prepare_comment(orig_comment)
        comment = orig_comment.clone.with_indifferent_access
        comment[:provider] = prepare_provider(Account.find(comment[:account_id]).rolable.to_hash)
        
        filter_comment = [:_id, :_type, :account_id, :context_id, :context_type, :active]
        comment.delete_if { |attr, val| filter_comment.include?(attr.to_sym) }
        
        comment
      end
      
      def prepare_offer(orig_offer)
        offer = orig_offer.clone.with_indifferent_access
        provider = offer[:provider_type].constantize.find(offer[:provider_id])
        offer[:provider] = prepare_provider(provider.to_hash)
        
        filter_offer = [:_id, :prices, :deleted_date, :provider_type, :provider_id, :phone_id]
        offer.delete_if { |attr, val| filter_offer.include?(attr.to_sym) }
        
        offer
      end
      
      def prepare_provider(orig_provider)
        provider = orig_provider.clone.with_indifferent_access
        filter_provider = [:followings, :followers]
        provider.delete_if { |attr, val| filter_provider.include?(attr) }
        
        provider
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