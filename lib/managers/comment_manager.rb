module Managers
  MINIMUN_COMMENT_LENGTH = 10
  MINIMUM_COMMENTS_TIME_FRAME = 1 #in mins
  
  
  module CommentManager
    def self.create(orig_account, text, opts = {})
      if orig_account.blank? || !text.is_a?(String) || text.length < MINIMUN_COMMENT_LENGTH || opts[:phone].blank?
        return {:status => false, :message => I18n.t("comments.parameters_invalid")}
      end
      account = orig_account.is_a?(Account) ? orig_account.reload : Account.find(orig_account)
      return {:status => false, :message => I18n.t("comments.account_not_found")} unless account
      phone = opts[:phone].is_a?(Phone) ? opts[:phone] : Phone.find(opts[:phone])
      return {:status => false, :message => I18n.t("comments.phone_not_found")} unless phone
      
      user_recent_comments = account.comments.where(:created_at.gte => DateTime.now - 5.minutes)
            
      unless user_recent_comments.select { |comment| comment.text.downcase == text.downcase }.empty?
        return {:status => false, :message => I18n.t("comments.max_one_with_same_text_5_mins")}
      end
      
      user_one_min_comments = user_recent_comments.select { |comment| comment.created_at > Time.new.utc - MINIMUM_COMMENTS_TIME_FRAME.minutes }      
      unless user_one_min_comments.empty?
        return {:status => false, :message => I18n.t("comments.max_one_in_1_min")}       
      end
      
      comment = account.comments.build(:text => text)
      comment.context = phone
      
      if comment.save && phone.save
        { :status => true, :message => I18n.t("comments.comment_saved"), :comment => comment }  
      else
        { :status => false, :message => I18n.t("comments.error_while_adding") }
      end
      
    end
  end
end