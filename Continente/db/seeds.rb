admin = User.create :email => "admin@example.com", :password => "password", :password_confirmation => "password"
admin.roles = User::ROLES
admin.save
