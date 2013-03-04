class ReviewsController < ApplicationController
  
  def create_phone_review
    if account_signed_in?
      phone_id = params[:phone_id]
      
      phone = Phone.find(phone_id)
      review = phone.reviews.build(params)
      review.account_id = current_account.id
      
      if review.save
        @phone = Phone.find(phone_id)
        render :partial => "review_added", :layout => nil
      end
    else
      render :partial => "shared/not_authorized", :layout => nil
    end
  end
  
end