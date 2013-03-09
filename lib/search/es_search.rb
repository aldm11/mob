require "tire"

module Search
  module ESSearch
 
    #simple search
    def search(name)
      query = Tire.search "catalogue_items" do
        query do
          if name
            boolean do
              should { match "phone.brand", name, { "operator" => "or" } }
              should { match "phone.model", name, { "operator" => "or" } }
            end
          else
            all
          end
        end
  
        filter :missing, :field => "deleted_date"
    
        facet "brands", :global => true do
          terms "phone.brand"
        end
  
        facet "provider" do
          terms "provider.name"
        end
      end
    end
    query
    
  end
end