class HomeInfo
  
  def initialize(options = {})
    search_filters = options && options[:brand] ? {"brand" => options[:brand]} : nil
    Search::ESSearch.search(:search_term => nil, :search_filters => search_filters)
  end
  
  def latest_phones(options = {})
    @phones = Search::ESSearch.results
    PhoneDecorator.decorate(@phones)    
  end
  
  def brands
    brands = Search::ESSearch.facets("brands").map {|brand| brand["term"]}
  end

end