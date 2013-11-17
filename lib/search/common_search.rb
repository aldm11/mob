module Search
  class CommonSearch
    
    @criterias = {}
    
    DEFAULT_CRITERIAS = {:search_term => nil, :search_filters => {}, :search_sort => {"latest_price.created_at" => "desc"}, :search_from=> 0, :search_size => 50}
        
    def self.add_methods
      class_eval do
        DEFAULT_CRITERIAS.each do |key, value|
          define_singleton_method(key.to_s) { DEFAULT_CRITERIAS[key] }
        end
      end
    end
    
    add_methods
    
  end
end