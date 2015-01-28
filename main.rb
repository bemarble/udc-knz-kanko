# coding: utf-8

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'active_record'
require './model.rb'
# require './impdata.rb'
require 'faraday'
require 'kconv'

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

class Message  < ActiveRecord::Base

end
class Opendatas < ActiveRecord::Base

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

    list = Post.find_by_sql(['SELECT * FROM posts AS p WHERE updated_at = (SELECT MAX(updated_at) FROM posts as s WHERE p.user_id=s.user_id) LIMIT 10']).map do |row|
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

  post '/user/' do

    if @params[:id]
      id = @params[:id]
      row = User.find(id)
    else
      row = {}
    end
    row.to_json
  end

  get '/login/' do
    erb :login
  end

  get '/me' do

    @user = session

    p @user[:facebook]
    erb :my
  end

  get '/:path' do
    path = params[:path]
    erb path.intern
  end

  post '/register_state' do

    posts = Post.new

    posts.user_id = session[:id]
    posts.message = @params[:message]
    posts.latitude = @params[:lat]
    posts.longitude = @params[:lng]


    posts.save
  end

  get '/opendata/' do
    # 座標を読み込むAPI
    #erb :geo, :layout => false

    @data = {
      :type => "FeatureCollection",
      :features => []
    }

    list = Opendatas.order("open_id ASC").map do |row|
      record = {
        :type => "Feature",
        :properties => {
          :description => row.name,
          :id => row.open_id,
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

  get '/admin/impdata/:pass' do
    @pass = params[:pass]
    @result = "bad request."
    if @pass == "udc_knz_kanko" then

      conn = Faraday::Connection.new(:url => 'http://www4.city.kanazawa.lg.jp') do |builder|
        builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
        # builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
        builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
      end
      response = conn.get '/data/open/cnt/3/20762/1/01kankou.csv' # GET http://example.com/api/nyan.json
      # @result = response.body

      # @result = response
      # hClient= HTTPClient.new
      # endpoint_uri = 'http://www4.city.kanazawa.lg.jp/data/open/cnt/3/20762/1/01kankou.csv'
      # tmp_data = hClient.get_content(endpoint_uri, "content-type" => "text/csv")
      tmp_data = response.body.kconv(Kconv::UTF8, Kconv::UTF16)
      @result = tmp_data
      csv_data = tmp_data.split("\t")
      row_count = 0;
      @save_data = []
      @record = {}
      for clm in csv_data do
        clm.delete!("\"")
        if row_count==20 then
          clm.each_line do |line|
            line.strip!
            line.slice!("\"")
            # puts line
            if row_count==20 then
              @record[:url] = line
              @save_data.push(@record)
              # puts "===end==="
              row_count = -1
              @record = {}
            else
              @record[:openid] = line
              row_count = row_count+1
            end
          end
        else
          case row_count
            # when 0 then
            #   @record[:openid] = clm
          when 1 then
            @record[:latitude] = clm
          when 2 then
            @record[:longitude] = clm
          when 9 then
            @record[:name] = clm
          when 10 then
            @record[:desc] = clm
          when 13 then
            @record[:tel] = clm
          end
          # puts clm
        end
        # puts row_count
        row_count = row_count+1
      end

      save_count = 0
      for save_row in @save_data do

        odata = Opendatas.find_by(open_id: save_row[:openid])

        if odata == nil
          odata = Opendatas.new
        end

        odata.open_id = save_row[:openid]
        odata.latitude = save_row[:latitude]
        odata.longitude = save_row[:longitude]
        odata.name = save_row[:name]
        odata.desc = save_row[:desc]
        odata.tel = save_row[:tel]
        odata.url = save_row[:url]

        odata.save

        save_count = save_count +1
      end
      @result = "更新しました。"
    end
    erb :impdata, :layout => false
  end

end
