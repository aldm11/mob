require "tire"

module Search
  module ESSearch
 
    include CommonSearch
 
    #TODO: test this
    FILTERS_MAPPINGS = {
      "prices" => lambda  do |price_range|
        filter :range, :from => price_range["from"], :to => price_range["to"]
      end,
      "brand" => lambda do |brand|
        filter :term, :brand => brand
      end
    }
    
    SORT_MAPPINGS = {
      "created_at" => lambda  do |sort_type|
        sort { by "created_at", sort_type }
      end
    }
 
    #simple search
    INDEX_NAME = "phones"
    def self.search
      q = Tire.search INDEX_NAME do
        #query
        query do
          if term
            boolean do
              should { match "brand", term, { "operator" => "or" } }
              should { match "model", term, { "operator" => "or" } }
              should  { prefix "brand", term }
              should { prefix "model", term }
            end
          else
            all
          end
        end
        
        #filters
        FILTERS_MAPPINGS.each do |key, value|
          MAPPINGS[key.to_s].call(value)
        end
  
        #TODO: sort - same as filters
    
        facet "brands", :global => true do
          terms "phone.brand"
        end
  
        facet "provider" do
          terms "provider.name"
        end
      end
      q
    end 
  end
end