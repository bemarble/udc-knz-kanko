require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?

require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-twitter'


class App < Sinatra::Base

    configure :development do
      register Sinatra::Reloader
    end

    configure do
      use Rack::Session::Cookie
    end

    use OmniAuth::Builder do
      SCOPE = 'email,read_stream'
      ENV['FB_APP_ID'] = "806086352763502"
      ENV['FB_APP_SECRET'] = "e2941a79f5beeab87d81abb9a2489996"

      ENV['TW_APP_ID'] = "d8fhQkymOTmCYnpasZvOM1qbq"
      ENV['TW_APP_SECRET'] = "tBwlj2YVQFk4nQPrCwMgHt5ffKPelhOdZRPDrMYZL7msBfZZsc"
      provider :facebook, ENV['FB_APP_ID'],ENV['FB_APP_SECRET'], :scope => SCOPE

      provider :twitter, ENV['TW_APP_ID'], ENV['TW_APP_SECRET']
    end

    get '/facebook' do
      if session[:facebook] == nil
        redirect '/auth/facebook'
      else
        @user = session
        erb :my
      end
    end

    get '/twitter' do
      if session[:twitter] == nil
        redirect '/auth/twitter'
      else
        @user = session
        erb :my
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
      session[info["provider"]] = true


      redirect '/'
    end


    get '/' do

		    erb :index
		end

    get '/place/' do
        p "testtesttest"
        p session[:user_name]
        erb :place
    end

    get '/geo/' do
        # 座標を読み込むAPI
        erb :geo, :layout => false
    end

    get '/my' do

      @user = session

      p @user[:facebook]
      erb :my
    end

    get '/:path' do
	      path = params[:path]
		    erb path.intern
    end
end
