# coding: utf-8
require 'sinatra'
require 'sinatra/base'
require 'active_record'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection('development')

class User < ActiveRecord::Base
end

class App < Sinatra::Base
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

  get '/db_test/' do
    v = User.first
    "#{v.name} / #{v.twitter} / #{v.facebook}"
    # "Hello #{User.count} users!"
  end

  get '/:path' do
    path = params[:path]
    erb path.intern
  end
end
