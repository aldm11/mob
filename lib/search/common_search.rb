module Search
  class CommonSearch
    
    @@criterias = {}
    
    DEFAULT_CRITERIAS = {:search_term => nil, :search_filters => {}, :search_sort => {"latest_price.created_at" => "desc"}, :search_from=> 0, :search_size => 50}
        
    def self.add_methods
      class_eval do
        DEFAULT_CRITERIAS.each do |key, value|
          define_singleton_method(key.to_s) { @@criterias && @@criterias[key] ? @@criterias[key] : DEFAULT_CRITERIAS[key] }
        end
      end
    end
    
    def self.set_criterias(new_criterias)      
      new_criterias = new_criterias.with_indifferent_access
      
      if @@criterias
        @@criterias[:search_filters] ||= DEFAULT_CRITERIAS[:search_filters]
        @@criterias[:search_filters] = @@criterias[:search_filters].merge(new_criterias[:search_filters]) if new_criterias[:search_filters]
  
        @@criterias[:search_term] = new_criterias[:search_term] || @@criterias[:search_term] || DEFAULT_CRITERIAS[:search_term]
        @@criterias[:search_sort] = new_criterias[:search_sort] || @@criterias[:search_sort] || DEFAULT_CRITERIAS[:search_sort]
        @@criterias[:search_from] = new_criterias[:search_from] || @@criterias[:search_from] || DEFAULT_CRITERIAS[:search_from]
        @@criterias[:search_size] = new_criterias[:search_size] || @@criterias[:search_size] || DEFAULT_CRITERIAS[:search_size]
      else
        @@criterias = DEFAULT_CRITERIAS.merge(new_criterias)
      end      
    end
    
    def self.reset_criterias
      @@criterias = DEFAULT_CRITERIAS
    end
    
    def self.get_criterias
      @@criterias
    end
    
    add_methods
    
  end
end