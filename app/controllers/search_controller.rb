class SearchController < ApplicationController
  before_filter :search_setup
    
  def index
    response = Search::ESSearch.search
    render :json => response.to_json
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