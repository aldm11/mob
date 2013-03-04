require '../app/models/account.rb'

email = "admin@mobis.ba"
password = "admin11"
name = "admin"

account = Account.new({:email => email, :password => password, :password_confirmation => password})
rolable = Admin.new({:name => name})
account.rolable = rolable

account.save
rolable.save
