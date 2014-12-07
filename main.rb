require 'sinatra'
require 'sinatra/base'

require 'omniauth'
require 'omniauth-facebook'

class App < Sinatra::Base

    SCOPE = 'email,read_stream'
    ENV['APP_ID'] = "806086352763502"
    ENV['APP_SECRET'] = "e2941a79f5beeab87d81abb9a2489996"

    use OmniAuth::Builder do
      provider :facebook, ENV['APP_ID'],ENV['APP_SECRET'], :scope => SCOPE
    end

    set :sessions, true

    use Rack::Session::Cookie

    get '/facebook' do
      if session[:uid] == nil
        redirect '/auth/facebook'
      else
        erb :index
      end
    end

    get '/logout' do
      session.clear
      erb :logout
    end

    get '/auth/:provider/callback' do
      info = request.env['omniauth.auth']
      session[:uid] = info["uid"]
      session[:user_name] = info["info"]["name"]
      session[:image]= info["info"]["image"]

      p info
      redirect '/'
    end


    get '/' do

		    erb :index
		end

    get '/place/' do
        erb :place
    end

    get '/geo/' do
        # 座標を読み込むAPI
        erb :geo
    end

    get '/:path' do
	      path = params[:path]
		    erb path.intern
    end
end
