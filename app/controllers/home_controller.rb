class HomeController < ApplicationController

  def index
    #TODO: find out better way to do this including sorting, pagind, filtering etc
    @options = params[:brand] ? {:brand =>  params[:bramd]} : {}
    @home_info = HomeInfo.new    
  end

  def about
  end

  def contact
  end
end
