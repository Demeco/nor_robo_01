# coding: utf-8

#=Sinatraを使ってWebアプリの体裁を保つためのファイル
=begin
HerokuのスケジューラとかアプリURLへのアクセスで実行させたい処理は全部ここに書く
=end

#==requireいろいろ
require 'sinatra'
require_relative 'tweet.rb'
require_relative 'twitlink.rb'
require_relative 'param.rb'

#==URL'/'でアクセス
get '/' do
  #窓口にする
  #ホームページの取説的な記事にリダイレクトさせたい
end

#==URL'/tester'でアクセス
get '/tester' do
  #いろいろテストする用
  test = Param.find('since_id')
  test.param + ":" + test.value.to_s
end

#==URL'/twitter-update'でアクセス
get '/twitter-update' do
  #こいつをスケジューラで叩いてTwitter更新する
end