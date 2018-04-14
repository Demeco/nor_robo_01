# coding: utf-8

require 'sinatra'
require_relative 'tweet.rb'
require_relative 'user.rb'

# URL'/'でアクセス
get '/' do
  'under construction'
end

# URL'/tester'でアクセス
get '/tester' do
  #Tweet.new.random_tweet
  test = User.find('since_id')
  '#{test.param}:#{test.value}'
end