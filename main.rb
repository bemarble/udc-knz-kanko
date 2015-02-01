# coding: utf-8

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'active_record'
require './model.rb'
# require './impdata.rb'
require 'faraday'
require 'kconv'
require_relative 'config/secretkeys.rb'

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
      key = SECRET[:PRODUCTION]
    else
      key = SECRET[:DEVELOP]
    end

    # 環境変数が読めなければファイルのものを使う
    ENV['FB_APP_ID'] = ENV['FB_APP_ID'] || key[:FB_APP_ID]
    ENV['FB_APP_SECRET'] = ENV['FB_APP_SECRET'] || key[:FB_APP_SECRET]

    ENV['TW_APP_ID'] = ENV['TW_APP_ID'] || key[:TW_APP_ID]
    ENV['TW_APP_SECRET'] = ENV['TW_APP_SECRET'] || key[:TW_APP_SECRET]

    provider :facebook, ENV['FB_APP_ID'],ENV['FB_APP_SECRET'], :scope => SCOPE

    provider :twitter, ENV['TW_APP_ID'], ENV['TW_APP_SECRET']
  end

  before do
    @css = ["/css/bootstrap.min.css", "/css/main.css"]
  end

  get '/' do

    erb :index
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

      row = User.find_by_sql(['SELECT LAST_INSERT_ID() AS id']).first

    end

    # IDを取得
    session[:id] = row[:id]

    redirect '/'
  end

  get '/place/' do

    @places = Opendatas.select("open_id,name").order("open_id ASC")

    @css.push "/css/map.css"
    @css.push "/css/bootstrap-switch.min.css"
    @css.push "/css/bootstrap-select.min.css"
    erb :place
  end

  get '/kml/post.kml' do
    content_type "text/xml"

    @data = {
      :type => "FeatureCollection",
      :features => []
    }

    @list = Post.find_by_sql(['SELECT p.*,o.name AS place FROM posts AS p,opendatas AS o WHERE o.open_id=p.open_id AND p.updated_at = (SELECT MAX(updated_at) FROM posts as s WHERE p.user_id=s.user_id OR s.user_id IS NULL) LIMIT 10'])

    erb :kml_post, :layout => false
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

    list = Post.find_by_sql(['SELECT p.*,o.name AS place FROM posts AS p,opendatas AS o WHERE o.open_id=p.open_id AND p.updated_at = (SELECT MAX(updated_at) FROM posts as s WHERE p.user_id=s.user_id OR s.user_id IS NULL) LIMIT 10']).map do |row|
      record = {
        :type => "Feature",
        :properties => {
          :description => row.message,
          :want_to_go => row.place,
          :id => row.user_id == nil ? '' : row.user_id,
          :updated_at => row.updated_at.strftime("%Y年 %m月%d日 %H:%M"),
          :icon =>  row[:help] == 1 ? "/img/help.png" : "/img/go.png",
        },
        :geometry => {
          :icon =>  row[:help] == 1 ? "/img/help.png" : "/img/go.png",
          :type => "Point",
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
    posts.help = @params[:help] == "true" ? 1 : 0
    posts.open_id = @params[:open_id]

    posts.save
  end

  get '/kml/opendata.kml' do
    content_type "text/xml"

    @list = Opendatas.order("open_id ASC")

    erb :opendata, :layout => false

  end
  get '/opendata/' do
    # 座標を読み込むAPI
    #erb :geo, :layout => false

    @data = {
      :type => "FeatureCollection",
      :features => []
    }

    Opendatas.order("open_id ASC").map do |row|
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

      Opendatas.connection.execute("TRUNCATE TABLE opendatas")

      save_count = 0
      for save_row in @save_data do

        odata = Opendatas.find_by(open_id: save_row[:openid])

        if odata == nil
          odata = Opendatas.new
        end

        if save_row[:openid] == nil
          next;
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
