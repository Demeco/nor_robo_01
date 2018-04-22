# coding: utf-8

#= ローカル実行用
=begin
ローカルで何か実行する用のスクリプト
辞書更新するのとかに使おうと思う
=end
require 'csv'
require 'twitter'
require_relative 'nor.rb'
require_relative 'tweet.rb'
require_relative 'param.rb'


#== 固定プロンプト
def prompt(nor)
  return nor.name + ':' + nor.responder_name + '>'
end

#== ログにツイートを追加する
def twitter_add_log(csv,tweet)
  log = [
    tweet.id,#id
    tweet.in_reply_to_status_id,#reply_id
    slice_mention(tweet.full_text.dup,tweet.user_mentions[0]),#text
    tweet.user.screen_name#user
    ]
    puts(log)
  csv << log
end

#== ログを保存する
def save_log(log)
  File.open(PATH_LOGS,'w') do |file|
    file.write(log)
  end
end

#受け取ったツイートから学習
def twitter_learning(nor,tweet)
  if tweet.user.screen_name != nor.name()#自分の発言は弾く
    text = Tweet.slice_mention(tweet.full_text.dup,tweet.user_mentions[0])
    t = nor.analyze(text)
  end
end


user_id = Tweet.load('user_id')
proto = Nor.new(user_id)
PATH_LOGS = proto.name + "/public/twitter_log.csv"
log_id = Tweet.load('log_id')
if __FILE__ == $0
  #ログの読み込み
  if File.exist?(PATH_LOGS) == false
    header = ["id","reply_id","text","user"]
    log_csv = CSV.open(PATH_LOGS,'w') do |csv|
      csv << header
    end
    save_log(log_csv)
  end
  log_csv = CSV.read(PATH_LOGS,headers: true,converters: :numeric,header_converters: :symbol)
  
  #Twitterクライアントを作成
  twClient = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token    = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
  
  #起動してモードを選択
  puts('Nor System prototype : proto')
  puts('---------LOCAL BOOT---------')
  while true
    puts("INFO : Twitter検索で文章自動学習させたかったらクエリを入れてね(最新100件まで検索)")
    puts("INFO : クエリ一覧→https://so-zou.jp/web-app/tech/web-api/twitter/search/search-query.htm")
    puts("INFO : 空Enterでログ更新を開始します")
    input = gets
    input.chomp!
    break if input == ""#空だったらbreakしてログ読み込みへすすむ
    search_tweets = twClient.search(input, count: 100, result_type: "recent", exclude: "retweets")
    search_tweets.take(100).each do |tweet|
      twitter_add_log(log_csv,tweet)
      twitter_learning(proto,tweet)
    end
    print("INFO : #{search_tweets.length}件のログを追加しました")
  end
  
  #最新の返答までログを更新
  replys_to_me = twClient.mentions_timeline(count: 100,since_id: log_id.to_i)
  replys_to_me.each do |reply|
    twitter_add_log(log_csv,reply)
    twitter_learning(proto,reply)
    puts('.')
  end
  if replys_to_me.length > 0
    log_id = replys_to_me[0].id.to_s#since_idを更新
    Tweet.save('log_id',log_id)
    print("INFO : #{replys_to_me.length}件のログを追加しました")
  end
  save_log(log_csv)
  proto.save()
  puts("Nor System prototype : proto")
  puts("-------SYNC COMPLETE--------")
  puts("INFO : 動作テストへ移行します")
  puts("INFO : 空白Enterで終了します")
  
  #動作テストモード
  while true
    print('YOU> ')
    input = gets
    input.chomp!
    break if input == ''
  
    response = proto.dialogue(input)
    puts(prompt(proto) + response)
  end
end