class SearchController < ApplicationController   
  
  def search_phones
    @from = params[:from] || 0
    @size = params[:size] || 0
    options = {
      :search_term => params[:search_term] || nil,
      :search_filters => {},
      :search_sort => params[:sort_by] || nil,
      :search_from => @from,
      :search_size => @size
    }
        
    options[:search_filters].merge!("brand" => params["brand"]) if params[:brand] && !params[:brand].empty?
    
    if params[:price_from] && params[:price_to]
      options[:search_filters].merge!("prices" => {"from" => params[:price_from], "to" => params[:price_to]})
      @min_price = params[:price_from].to_f
      @max_price = params[:price_to].to_f
    end
    
    Search::ESSearch.search(options)
    @phones = Search::ESSearch.results
    @phones = PhoneDecorator.decorate(@phones)
    @brands = Search::ESSearch.facets("brands")
        
    respond_to do |format|
      format.js if request.xhr?
      format.html { render "home/index" }
    end
  end
  
  def index
    
  end
  
  def advanced_search
    render :json => Search::CommonSearch.get_criterias.to_json
  end
  
end