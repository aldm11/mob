module Managers
  module UserManager
    
    def self.get_all_users
      users = []
      User.find(:all).each do |user|
        users << user
      end
      users
    end
    
  end
end