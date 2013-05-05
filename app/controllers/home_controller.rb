class HomeController < ApplicationController

  def index    
    search_filters = params[:brand] ? {:brand =>  params[:brand]} : nil
    Search::ESSearch.search(:search_term => nil, :search_filters => search_filters)
    @phones = Search::ESSearch.results
    @phones = PhoneDecorator.decorate(@phones) 
    @brands = Search::ESSearch.facets("brands").map {|brand| brand["term"]}
  end

  def about
  end

  def contact
  end
end
