class ReviewsController < ApplicationController
  before_filter :only_signed_in_users, :only => [:create_phone_review]
  def create_phone_review
    phone_id = params[:phone_id]
    
    @phone = Phone.find(phone_id)
    @add_result = Managers::PhoneManager.add_review(current_account, @phone, params[:like] ? true : false)    
  end
  
end