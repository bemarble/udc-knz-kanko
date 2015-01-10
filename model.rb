configure :development, :test do
    ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
    # use Rack::Auth::Basic do |username, password|
    #    username == 'admin' && password == 'admin'
    # end
end

configure :production do
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
    # use Rack::Auth::Basic do |username, password|
    #    username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
    # end
end
