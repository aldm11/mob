class Api::V1::PhonesController < ApplicationController
  respond_to :json, :xml
  
  def index
    @phones = Managers::PhoneManager.get_phones
    respond_with(@phones)
  end
  
end