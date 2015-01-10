# coding: utf-8

# import sinatra-rake
require 'sinatra/activerecord/rake'

require_relative 'config/database.rb'

task default: [:help] do
end

desc '説明書'
task help: [] do
  sh 'bundle exec rake -f Rakefile.db -T'
end
