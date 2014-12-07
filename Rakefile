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

  desc 'bundle install'
  task bundle: [] do
    sh 'bundle install --path vendor/bundle'
  end

  task print_git_remote: [] do
    puts '以下の設定でやることをオススメ'
    puts 'git remote set-url origin git@github.com:bemarble/udc-knz-kanko.git'
    puts 'git remote add heroku  git@heroku.com:udc-knz-kanko.git'
  end

end
