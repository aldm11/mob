class HomeController < ApplicationController

  def index
    # this action is submitted using javascript
    @brand = params[:brand] || nil
    
    Search::ESSearch.search(:search_filters => {"camera.mpixels" => {"from" => 6, "to" => 10}})
    phones = Search::ESSearch.results
    raise phones.inspect
  end

  def about
  end

  def contact
  end
end
