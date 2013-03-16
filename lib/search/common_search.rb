module Search
  module CommonSearch
    
    @@criterias = {}
    
    DEFAULT_CRITERIAS = {:term => nil, :filters => {}, :sort => {"latest_price.created_at" => "desc"}, :from=> 0, :size => 50}
        
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
        @@criterias[:filters] ||= DEFAULT_CRITERIAS[:filters]
        @@criterias[:filters] = @@criterias[:filters].merge(new_criterias[:filters]) if new_criterias[:filters]
  
        @@criterias[:term] = new_criterias[:term] || @@criterias[:term] || DEFAULT_CRITERIAS[:term]
        @@criterias[:sort] = new_criterias[:sort] || @@criterias[:sort] || DEFAULT_CRITERIAS[:sort]
        @@criterias[:from] = new_criterias[:from] || @@criterias[:from] || DEFAULT_CRITERIAS[:from]
        @@criterias[:size] = new_criterias[:size] || @@criterias[:size] || DEFAULT_CRITERIAS[:size]
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