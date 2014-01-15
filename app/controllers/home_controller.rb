class HomeController < ApplicationController

  def index
    Phone.reindex_all
    # this action is submitted using javascript
    @brand = params[:brand] || nil
  end

  def about
  end

  def contact
  end
end
