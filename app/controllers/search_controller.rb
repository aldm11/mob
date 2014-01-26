class SearchController < ApplicationController   
  
  # types - string (default), bool, number, numeric_range_from, numeric_range_until, numeric_range, date_range_from, date_range_until, date_range
  FILTERS = {
    :brand => {:name => "brand"},
    :operating_system => {:name => "os"},
    :weight => {:name => "weight"},
    :internal_memory => {:name => "internal_memory"},
    :external_memory => {:name => "external_memory"},
    :camera_mpx => {:name => "camera.mpixels", :type => "numeric_range_until"},
    :camera_blic => {:name => "camera.blic", :type => "bool"},
    :camera_front => {:name => "camera.front", :type => "bool"},
    :camera_video => {:name => "camera.video", :type => "bool"}
  }
  def search_phones
    @from = params[:from] || 0
    @size = params[:size] || 0
    options = {
      :search_term => params[:search_term] || nil,
      :search_filters => {},
      :search_sort => params[:sort_by] || nil,
      :search_from => @from,
      :search_size => @size
    }
        
    # options[:search_filters].merge!("brand" => params["brand"]) if params[:brand] && !params[:brand].empty?
    options[:search_filters] = Hash[
      params.select { |param, value| FILTERS.keys.include?(param.to_sym) }.map do |param, value| 
        val = value
        val = val == "1" ? true : false if FILTERS[param.to_sym][:type] && FILTERS[param.to_sym][:type] == "bool"
        val = val.to_f if FILTERS[param.to_sym][:type] && FILTERS[param.to_sym][:type] == "number"
        val = {"from" => val.to_f} if FILTERS[param.to_sym][:type] && FILTERS[param.to_sym][:type] == "numeric_range_from"
        val = {"to" => val.to_f} if FILTERS[param.to_sym][:type] && FILTERS[param.to_sym][:type] == "numeric_range_until"
        val = {"from" => val.split("-").first.strip.to_f, "to" => val.split("-").last.strip.to_f} if FILTERS[param.to_sym][:type] && FILTERS[param.to_sym][:type] == "numeric_range"
        
        [FILTERS[param.to_sym][:name], val]
      end
    ]
        
    if params[:price_from] && params[:price_to]
      options[:search_filters].merge!("prices" => {"from" => params[:price_from], "to" => params[:price_to]})
      @min_price = params[:price_from].to_f
      @max_price = params[:price_to].to_f
    end
    
    Search::ESSearch.search(options)
    @phones = Search::ESSearch.results
    @phones = PhoneDecorator.decorate(@phones)
    @brands = Search::ESSearch.facets("brands")
        
    respond_to do |format|
      format.js if request.xhr?
      format.html { render "home/index" }
    end
  end
  
  def index
    
  end
  
  def advanced_search
    render :json => Search::CommonSearch.get_criterias.to_json
  end
  
end