class PhonesController < ApplicationController
  
  def show
    id = params[:id]
    Search::ESSearch.search
    @brands = Search::ESSearch.facets("brands")
    @phone = PhoneDecorator.decorate(Phone.find(id)) rescue nil   
    
    if @phone
      unless @phone.catalogue_items.empty?
        @catalogue_items = @phone.catalogue_items.select {|ci| ci.deleted_date.nil? }.sort {|a, b| b.date_from <=> a.date_from}
        @prices = @catalogue_items.map { |ci| ci.actual_price }.sort
        @min_price = @prices.first
        @max_price = @prices.last
      end 
      
      @comments = @phone.comments.sort {|a, b| b.created_at <=> a.created_at} unless @phone.comments.empty?
    end 
  end
  
end
