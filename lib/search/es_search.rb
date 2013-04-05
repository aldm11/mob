require "tire"
module Search
  class ESSearch < CommonSearch
  
    #TODO: test this
    @@facets = nil
    @@results = nil
    
    FILTERS_MAPPINGS = {
      "prices" => lambda  do |s, price_range|
        if s && price_range && price_range["from"] && price_range["to"]
          s.filter :range, :from => price_range["from"], :to => price_range["to"]
        else
          error = "Invalid parameters for price range filter"
          Rails.logger.error error
          raise error
        end
      end,
      "brand" => lambda do |s, brand|
        if s && brand
          s.filter :term, "brand.original" => brand
        else
          error = "Invalid parameters for brand term filter"
          Rails.logger.error error
          raise error
        end
      end
    }
    
    SORT_MAPPINGS = {
      "created_at" => lambda  do |s, sort_type|
        s.sort { by "latest_price.created_at", sort_type }
      end,
      "price" => lambda do |s, sort_type|
        s.sort { by "catalogue_items.actual_price", sort_type }
      end
    }
 
    INDEX_NAME = "phones"
    
    #TODO: support for choosing fields in response(performance issue, response should not be to long)
    #TODO: additional optional parameter for response format - array of hashes or array of models
    def self.search(options = nil)
      options = options.with_indifferent_access if options && options.is_a?(Hash)
      term = options && options[:search_term] ? options[:search_term] : search_term
      filters = options && options[:search_filters] ? options[:search_filters] : search_filters
      filters = filters.with_indifferent_access
      sorts = options && options[:search_sort] ? options[:search_sort] : search_sort
      from = options && options[:search_from] ? options[:search_from] : search_from
      size = options && options[:search_size] ? options[:search_size] : search_size
           
      s = Tire.search(INDEX_NAME)     
      if search_term
        s.query do
          boolean do
            should { match "brand", term, { "operator" => "or" } }
            should { match "model", term, { "operator" => "or" } }
            should  { prefix "brand", term }
            should { prefix "model", term }
          end
        end
      else
        s.query { all }
      end
        
      filters.each do |key, value|
        FILTERS_MAPPINGS[key.to_s].call(s, value) if FILTERS_MAPPINGS[key.to_s]
      end

      sorts.each do |key, value|
        SORT_MAPPINGS[key.to_s].call(s, value) if SORT_MAPPINGS[key.to_s]
      end
      
      s.from(from)
      s.size(size)
  
      s.facet "brands", :global => true do
        terms "brand.original"
      end

      s.facet "providers" do
        terms "catalogue_items.provider.name"
      end    
      
      @@results = s.results
      
      s
    end
    
    def self.results
      @@results
    end
    
    def self.facets(type)
      @@results.facets[type]["terms"]
    end
    
    def es_result_to_hash
      #TODO: implement this
    end
    
  end
end