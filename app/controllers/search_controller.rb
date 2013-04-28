class SearchController < ApplicationController   
  SORT_MAPPINGS = {
    :date => {"created_at" => "desc"},
    :price => {"price" => "desc"}
  }
  
  def index
    options = {
      :search_term => params[:search_term] || nil,
      :search_filters => {},
      :search_sort => params[:sort_by] ? SORT_MAPPINGS[params[:sort_by].to_sym] : nil,
      :search_from => params[:from] || 0,
      :search_size => params[:size] || 16
    }
    options[:search_filters].merge!("brand" => params["brand"]) if params[:brand] && !params[:brand].empty?
    #options[:search_filters].merge!("prices" => {"from" => params[:price_from], "to" => params[:price_to]})
    Search::ESSearch.search(options)
    @phones = Search::ESSearch.results
    @phones = PhoneDecorator.decorate(@phones)
    @brands = Search::ESSearch.facets("brands")
    
    respond_to do |format|
      format.js if request.xhr?
      format.html { render "home/index" }
    end
  end
  
  def advanced_search
    render :json => Search::CommonSearch.get_criterias.to_json
  end
  
end