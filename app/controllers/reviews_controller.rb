class ReviewsController < ApplicationController
  before_filter :only_signed_in_users, :only => [:create_phone_review]
  def create_phone_review
    phone_id = params[:phone_id]
    
    @phone = Phone.find(phone_id)
    review_props = {:like => params[:like] ? true : false, :account_id => current_account.id}
    review = @phone.reviews.build(review_props)
        
    if review.save
      @phone.save
    else
      redirect_to(:controller => "application", :action => "show_error")
    end
  end
  
end