module Search
  module DatabaseSearch
  
    CRITERIA_MAPPINGS = {
      :name => {
        :exec => "for_js"
      },
      :os => {
        :exec => "where(os: /$value/i)"
      }
    }
    #TODO: use class_eval for this, replace $value with attribute for that argument
  
    def search(criteria = {})
      
    end
    
  end
end