module AccountHelper
  
  DEFAULT_USERNAME_LENGTH = 8
  #TODO: filter chars that are not allowed
  def form_username(email)
    formed_username = email.split("@")[0]
    return formed_username if formed_username.length >= 6
    
    size = DEFAULT_USERNAME_LENGTH - formed_username.length    
    while true
      formed_username = [formed_username, (1..size).to_a].flatten.join
      break if Account.where(username: formed_username).to_a.empty?
      size = size + 1
    end
    formed_username
  end
  
end
