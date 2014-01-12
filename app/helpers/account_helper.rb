module AccountHelper
  
  MIN_USERNAME_LENGTH = 6
  #TODO: filter chars that are not allowed
  FORBIDDEN_USERNAME_CHARS = /\?|\<|\>|\'|\.|\,|\?|\[|\]|\}|\{|\=|\)|\(|\*|\&|\|^|\%|\$|\#|\`|\~|/
  def form_username(email)
    formed_username = email.split("@")[0]
    formed_username = formed_username.gsub(FORBIDDEN_USERNAME_CHARS, "")
    
    return formed_username if formed_username.length >= MIN_USERNAME_LENGTH
    
    size = MIN_USERNAME_LENGTH - formed_username.length    
    while true
      formed_username = [formed_username, (1..size).to_a].flatten.join
      break if Account.where(username: formed_username).to_a.empty?
      size = size + 1
    end
    formed_username
  end
  
  def property_editable?(property)
    Managers::AccountManager.editable?(property)
  end
  
end
