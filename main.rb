require 'sinatra'
require 'sinatra/base'

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
    get '/login/' do
      
      erb :login
    end
    get '/tw_login/' do

      # twitter login
      erb :tw_login
    end

    get '/:path' do
	      path = params[:path]
		    erb path.intern
    end
end
