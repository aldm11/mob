class SearchController < ApplicationController
  before_filter :search_setup
    
  def index
    Search::ESSearch.search(:search_term => params[:term])
    @phones = Search::ESSearch.results
    @brands = Search::ESSearch.facets("brands")
    
    render "home/index"
  end
  
  def advanced_search
    render :json => Search::CommonSearch.get_criterias.to_json
  end
  
  private
  def search_setup
    criterias = params[:criterias].is_a?(String) ? JSON.parse(params[:criterias]) : params[:criterias]
    Search::CommonSearch.set_criterias(criterias)
  end
end