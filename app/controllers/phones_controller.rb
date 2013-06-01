class PhonesController < ApplicationController
  
  def show
    id = params[:id]
    Search::ESSearch.search
    @brands = Search::ESSearch.facets("brands")
    @phone = PhoneDecorator.decorate(Phone.find(id)) rescue nil   
    
    if @phone
      unless @phone.catalogue_items.empty?
        @all_offers = @phone.catalogue_items.select {|ci| ci.deleted_date.nil? }.sort {|a, b| b.date_from <=> a.date_from}
        @offers = @all_offers ? @all_offers[0..0] : []
        @prices = @offers.map { |ci| ci.actual_price }.sort
        @min_price = @prices.first
        @max_price = @prices.last
        @last_offer = @offers.first
      end
      @all_comments = @phone.comments.select {|comm| comm.active}.sort {|a, b| b.created_at <=> a.created_at} unless @phone.comments.empty?
      @comments = @all_comments ? @all_comments[0..9] : []
    end 
  end
  
end
