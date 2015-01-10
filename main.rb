# coding: utf-8
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?

require './model.rb'

class User < ActiveRecord::Base
end

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

    before do
      @css = ["/css/bootstrap.min.css", "/css/main.css"]
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
      @css.push "/css/map.css"
      erb :place
    end

    get '/db_test/' do
      v = User.first
      "#{v.name} / #{v.twitter} / #{v.facebook}"
      # "Hello #{User.count} users!"
    end

    get '/geo/' do
        # 座標を読み込むAPI
        erb :geo, :layout => false
    end

    get '/login/' do
      erb :login
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
