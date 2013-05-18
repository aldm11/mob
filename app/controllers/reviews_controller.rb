class ReviewsController < ApplicationController
  before_filter :only_signed_in_users, :only => [:create_phone_review]
  def create_phone_review
    phone_id = params[:phone_id]
    
    phone = Phone.find(phone_id)
    review = phone.reviews.build(params)
    review.account_id = current_account.id
    
    if review.save
      phone.save
      @phone = Phone.find(phone_id)
    else
      redirect_to(:controller => "application", :action => "show_error")
    end
  end
  
end