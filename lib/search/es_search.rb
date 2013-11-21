require "tire"
module Search
  class ESSearch < CommonSearch
  
    @@facets = nil
    @@results = nil
    
    SORT_ORDER = {
      :relevance => {"relevance" => "desc"},
      :date => {"created_at" => "desc"},
      :price => {"price" => "desc"}
    }
    
    FILTERS_MAPPINGS = {
      "prices" => lambda  do |s, price_range|
        if s && price_range && price_range["from"] && price_range["to"]
          s.filter :nested, :path => "catalogue_items", :query => {:range => {"catalogue_items.actual_price" => { :from => price_range["from"], :to => price_range["to"] } } }
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
      end,
      "relevance" => lambda do |s, sort_type|
        s.sort { by "_score", sort_type }
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
      sorts = options && options[:search_sort] ? SORT_ORDER[options[:search_sort].to_sym] : search_sort
      from = options && options[:search_from] ? options[:search_from] : search_from
      size = options && options[:search_size] ? options[:search_size] : search_size
               
      s = Tire.search(INDEX_NAME)     
      if term
        s.query do
          boolean do
            should { match "brand.analyzed", term, { "operator" => "or" } }
            should { prefix "brand.analyzed", term }
            should { term "brand.original", term }
            should { match "model.analyzed", term, { "operator" => "or" } }
            should { prefix "model.analyzed", term  }
            should { prefix "model.original", term }
          end
        end
      else
        s.query { all }
      end
            
      s.filter :nested, :path => "catalogue_items", :query => {
        :filtered => {
          "query" => { "match_all" => {} }, 
          "filter" => { 
            "exists" => { "field" => "actual_price" }
          } 
        } 
      }

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
      
      puts "Elastic search request #{s.to_curl}"
      @@results = s.results
      
      s
    end
    
    def self.results
      @@results
    end
    
    def self.facets(type, facet_type = "term")
      @@results.facets[type]["terms"].map { |facet| facet[facet_type] }
    end
    
    def es_result_to_hash
      #TODO: implement this
    end
    
  end
end