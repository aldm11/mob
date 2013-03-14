require "tire"

module Search
  module ESSearch
 
    #simple search
    DEFAULT_OPTIONS = {:sort => "latest_price.created_at"}
    INDEX_NAME = "phones"
    def search(name, options = {})
      options = options.with_indifferent_access
      options = DEFAULT_OPTIONS.merge(options)
      
      q = Tire.search INDEX_NAME do
        query do
          if name
            boolean do
              should { match "brand", name, { "operator" => "or" } }
              should { match "model", name, { "operator" => "or" } }
              should  { prefix "brand", name }
              should { prefix "model", name }
            end
          else
            all
          end
        end
  
        sort { by options[:sort], "desc" }
    
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