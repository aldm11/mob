class PhonesController < ApplicationController
  
  def show
    id = params[:id]
    Search::ESSearch.search
    @brands = Search::ESSearch.facets("brands")
    @phone = PhoneDecorator.decorate(Phone.find(id)) rescue nil   
    
    if @phone
      unless @phone.catalogue_items.empty?
        offers_details = Managers::PhoneManager.get_offers(@phone, {:from => 0, :to => 0, :sort_by => "date"})
        @all_offers = offers_details[:all_offers]
        @offers = offers_details[:related_offers]
        @min_price = offers_details[:min_price]
        @max_price = offers_details[:max_price]
        @last_offer = @offers.first
      end
      comments_details = Managers::PhoneManager.get_comments(@phone, {:from => 0, :to => 9, :sort_by => "date"})
      @all_comments = comments_details[:all_comments]
      @comments = comments_details[:related_comments]
    end 
  end
  
end
