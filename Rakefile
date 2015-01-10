# coding: utf-8
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './models/opendata.rb'

# import sinatra-rake
require 'sinatra/activerecord/rake'

# import database_config
require './app.rb'

require_relative 'Rakefile.my'

task default: [:help] do
end

desc '説明書'
task help: [] do
  sh 'bundle exec rake -f Rakefile.db -T'
end
