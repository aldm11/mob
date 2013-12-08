class HomeController < ApplicationController

  def index    
    # this action is submitted using javascript
    @brand = params[:brand] || nil
  end

  def about
  end

  def contact
  end
end
