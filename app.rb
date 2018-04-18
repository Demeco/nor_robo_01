# coding: utf-8

require 'sinatra'
require_relative 'tweet.rb'
require_relative 'param.rb'

# URL'/'でアクセス
get '/' do
  'under construction'
end

# URL'/tester'でアクセス
get '/tester' do
  #Tweet.new.random_tweet
  test = Param.find('since_id')
  test.param + ":" + test.value.to_s
end