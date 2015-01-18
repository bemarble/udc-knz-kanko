# coding: utf-8
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'active_record'
require './model.rb'

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
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

    if ENV['RACK_ENV'] == "production"
      # production
      ENV['FB_APP_ID'] = "806086352763502"
      ENV['FB_APP_SECRET'] = "e2941a79f5beeab87d81abb9a2489996"

      ENV['TW_APP_ID'] = "d8fhQkymOTmCYnpasZvOM1qbq"
      ENV['TW_APP_SECRET'] = "tBwlj2YVQFk4nQPrCwMgHt5ffKPelhOdZRPDrMYZL7msBfZZsc"
    else
      # develop
      ENV['FB_APP_ID'] = "826355644069906"
      ENV['FB_APP_SECRET'] = "64495b9647fa2d8a4e8aa6843ec7b803"

      ENV['TW_APP_ID'] = "6RqWrX89FG44iHML0ci2eL6g3"
      ENV['TW_APP_SECRET'] = "MR5OuYN6nFRXOeDfQa8e9ITYNfEjW32erNvRpKalsJMi1TroR0"
    end


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

    row = User.find_by(info["provider"], info["uid"])

    if row == nil
      users = User.new
      users.name = info["info"]["name"]

      case info["provider"]
      when "twitter"
        users.twitter = info["uid"]
      when "facebook"
        users.facebook = info["uid"]
      end

      users.save

      row = User.find_by_sql(['SELECT LAST_INSERT_ID() AS id'])

    end

    # IDを取得
    session[:id] = row[:id]

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
    #erb :geo, :layout => false

    @data = {
      :type => "FeatureCollection",
      :features => []
    }

    list = Post.order("created_at DESC").limit(10).map do |row|
      record = {
        :type => "Feature",
        :properties => {
          :description => row.message,
          :id => row.user_id,
          :updated_at => row.updated_at.strftime("%Y年 %m月%d日 %H:%M")
        },
        :geometry => {
          :type => "Point",
          :icon =>  "/img/icon.gif",
          :coordinates => [
            row.longitude,
            row.latitude
          ]
        }
      }
      @data[:features].push(record)

    end

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

  post '/register_state' do
    message =

    posts = Post.new

    posts.user_id = session[:id]
    posts.message = @params[:message]
    posts.latitude = @params[:lat]
    posts.longitude = @params[:lng]
    posts.save

  end
end
