# add default admin user
user = User.new
user.email = 'test@test.com'
user.name = 'Honeybadger'
user.username = 'admin'
user.password = 'asdfasdf'
user.password_confirmation = user.password
user.role = 'admin'
user.provider = 'email'
user.avatar_url = '/vendor/honeybadger/img/avatar.jpg'
user.save
