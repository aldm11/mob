class PhoneData
  attr_accessor :phone
  attr_accessor :comment
  attr_accessor :user
  attr_accessor :comments

  def initialize(account, phone_id)
    @user = account
    @phone = PhoneDecorator.decorate(Phone.find(phone_id))
    @comment = Comment.new
    @comment.account = @user
    
    @comments = @phone.comments
  end
end