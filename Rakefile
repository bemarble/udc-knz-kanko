# coding: utf-8

task default: [:help] do
end

desc '説明書'
task help: [] do
  sh 'rake -T'
end

namespace :setup do

  desc 'init setup'
  task init: [] do
    sh 'bundle install --path vendor/bundle'
  end

end
