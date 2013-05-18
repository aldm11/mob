module Managers
  module UserManager
    
    def self.get_all_users
      accounts = []
      User.find(:all).each do |user|
        accounts << user
      end
      Store.find(:all).each do |store|
        accounts << store
      end
      accounts
    end
    
  end
end