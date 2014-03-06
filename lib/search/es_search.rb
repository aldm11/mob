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
        end
      end,
      "brand" => lambda do |s, value|
        s.filter :term, "brand.original" => value if s && value
      end,
      "os" => lambda do |s, value|
        s.filter :prefix, "os.analyzed" => value if s && value
      end,
      "camera.mpixels" => lambda do |s, value|
        if s && value && (value["from"] || value["to"])
          criteria = {}
          criteria[:lte] = value["from"] if value["from"]
          criteria[:gte] = value["to"] if value["to"]
          s.filter :numeric_range, "camera.mpixels" => criteria
        end
      end,
      "camera.blic" => lambda do |s, value|
        s.filter :term, "camera.blic" => value if s && value
      end,
      "camera.video" => lambda do |s, value|
        s.filter :term, "camera.video" => value if s && value
      end,
      "camera.front" => lambda do |s, value|
        s.filter :term, "camera.front" => value if s && value
      end,
      "display.type" => lambda do |s, value|
        s.filter :term, "display.type" => value if s && value
      end,
      "display.front" => lambda do |s, value|
        s.filter :term, "display.front" => value if s && value
      end,
      "internal_memory" => lambda do |s, value|
        if s && value && (value["from"] || value["to"])
          criteria = {}
          criteria[:gte] = value["from"] if value["from"]
          criteria[:lte] = value["to"] if value["to"]
          s.filter :numeric_range, "internal_memory" => criteria
          
          # code below for or filtering to take care of missing internal memory values
          # s.filter :bool, {:should => [
            # {"numeric_range" => {"internal_memory" => criteria}},
            # {"missing" => {"field" => "internal_memory"}}
          # ]}
          
        end
      end,
      "external_memory" => lambda do |s, value|
        if s && value && (value["from"] || value["to"])
          criteria = {}
          criteria[:gte] = value["from"] if value["from"]
          criteria[:lte] = value["to"] if value["to"]
          s.filter :numeric_range, "external_memory" => criteria
        end
      end,
      "weight" => lambda do |s, value|        
        if s && value && (value["from"] || value["to"])
          criteria = {}
          criteria[:gte] = value["from"] if value["from"]
          criteria[:lte] = value["to"] if value["to"]
          s.filter :numeric_range, "weight" => criteria
        end
      end,
      "date_manufectured" => lambda do |s, value|
        if s && value && (value["from"] || value["to"])
          criteria = {}
          criteria[:gte] = value["from"] if value["from"]
          criteria[:lte] = value["to"] if value["to"]
          s.filter :numeric_range, "date_manufectured" => criteria
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
            should { term "os.original", term }
            should { prefix "os.analyzed", term }
            should { prefix "brand.ngram_analyzed", term }
            should { prefix "model.ngram_analyzed", term }
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
      
      s.filter :term, "deleted" => false

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