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
  
  def index
    Search::ESSearch.search
    @brands = Search::ESSearch.facets("brands")
    @brands = Hash[@brands.map { |brand| [brand, brand] }]

    @search_options = {
      :os => {"" => "Svi", "android" => "Android", "ios"=> "iOS", "windows_phone" => "Windows Phone"},
      :weight => {"" => "Sve", 80 => "do 80 grama", 100=> "do 100 grama", 120 => "do 120 grama", 150 => "do 150 grama", 1000 => "preko 150 grama"},
      :brand => {"" => "Svi"}.merge(@brands),
      :internal_memory => {"" => "/", 256 => "256 MB", 512 => "512 MB", 1000 => "1 GB", 2000 => "2 GB", 4000 => "4 GB"},
      :external_memory => {"" => "/", 1000 => "1 GB", 2000 => "2 GB", 4000 => "4 GB", 8000 => "8 GB", 16000 => "16 GB", 32000 => "32 GB00"},
      :camera => {
        :mpx => {"" => "/", 2 => "ne manje od 2", 3.2 => "ne manje od 3.2", 4 => "ne manje od 4", 5 => "ne manje od 5", 6 => "ne manje od 6", 8 => "ne manje od 8", 12 => "ne manje od 12"},
        :video => {"" => "/", 1 => "DA", 0 => "NE"},
        :blic => {"" => "/", 1 => "DA", 0 => "NE"},
        :front => {"" => "/", 1 => "DA", 0 => "NE"}
      }
    }
    @brand = params[:brand]
    @search_term = params[:search_term]
  end
  
end
