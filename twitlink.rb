# coding: utf-8
#TwitterAPI経由でRubyからツイートするスクリプト

#= TwitterとNORの橋渡しをするクラス
=begin
Schedulerで実行するファイルでもある
=end

require 'twitter'
require 'active_support'
require 'active_support/core_ext'
require 'csv'
require_relative 'nor.rb'
require_relative 'param.rb'


#== since_idを有効にするモンキーパッチ
=begin
使わせていただいてます https://qiita.com/riocampos/items/6999a52460dd7df941ea
=end
module Twitter
  class SearchResults
    def next_page
      return nil unless next_page?
      hash = query_string_to_hash(@attrs[:search_metadata][:next_results])
      since_id = @attrs[:search_metadata][:since_id]
      hash[:since_id] = since_id unless since_id.zero?
      hash
    end
  end
end

PATH_LOGS = "public/twitter_log.csv"
since_id = Param.find('since_id').value

#== 各種値をdatabaseから引っ張ってくる
=begin
key キーの名前(ex:since_id(String)
value 値(Integer)
=end
def load(key)
  if Param.find(key)
    return Param.find(key).value
  end
end

#== 各種値をdatabaseに保存する
=begin
key キーの名前(ex:since_id(String)
value 値(Integer)
=end
def save(key,value)
  if Param.find(key)
    Param.find(key).update_attribute(:value,value)
  end
end

#設定保存
def save_setting(settings)
  File.open(PATH_SETTINGS,'w') do |f|
    settings.each do |key,value|
      if value == nil
        value = ''
      end
      f.puts(key + ":" + value.to_s())
    end
  end
end

#ログ保存
def save_log(log)
  File.open(PATH_LOGS,'w') do |file|
    file.write(log)
  end
end

#定型プロンプト
def prompt(nor)
  return nor.name + ':' + nor.responder_name + '>'
end

#最初の@メンションを切り取る
def slice_mention(text,mention)
  if mention != nil
        num = mention.indices[1]-mention.indices[0]
        text.slice!(mention.indices[0],num)
  end
  return text
end

#ログイン時処理
def twitter_login()
  
end

#ログアウト時処理
def twitter_logout()
  
end

#受け取ったツイートから学習
def twitter_learning(nor,tweet)
  if tweet.user.screen_name != nor.name()#自分の発言は弾く
    text = slice_mention(tweet.full_text.dup,tweet.user_mentions[0])
    t = nor.dialogue(text)
  end
end

#ログにツイートを追加する
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

#-----
#実行時
#-----
#Twitter設定ファイルを読み込み
if File.exist?(PATH_SETTINGS)
    File.open(PATH_SETTINGS) do |f|
      f.each do |line|
        line.chomp!
        next if line.empty?
        arr = line.split(':')
        settings_hash[arr[0]] = arr[1]
      end
    end
end
#なかったときにそなえてセーブ
save_setting(settings_hash)

#ログの読み込み
if File.exist?(PATH_LOGS) == false
  header = ["id","reply_id","text","user"]
  log_csv = CSV.open(PATH_LOGS,'w') do |csv|
    csv << header
  end
  save_setting(settings_hash)
end
log_csv = CSV.read(PATH_LOGS,headers: true,converters: :numeric,header_converters: :symbol)

#クライアントを作成
#セキュリティのため環境変数で設定してね
twClient = Twitter::REST::Client.new do |config|
    config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token    = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

#人工無脳本体を作成
proto = Nor.new(settings_hash['user_id'])

#プロンプトで読み込み学習するかどうか聞く
while true
  puts("Twitter検索で文章自動学習させたかったらクエリを入れてね(最新100件まで検索)")
  puts("クエリ一覧→https://so-zou.jp/web-app/tech/web-api/twitter/search/search-query.htm")
  puts("空Enterで起動します")
  input = gets
  input.chomp!
  break if input == ""#空だったらbreakして起動
  search_tweets = twClient.search(input, count: 100, result_type: "recent", exclude: "retweets")
  search_tweets.take(100).each do |tweet|
    twitter_add_log(log_csv,tweet)
    twitter_learning(proto,tweet)
  end
  save_log(log_csv)
  proto.save()
end

# 1回の実行につき継続して動かしたい時間の間だけループする
loop_minutes = load('loop_minutes')*60
# TwitterAPIの制限に引っかからない程度にツイートを取得する間隔(秒)
INTERVAL_SECOND = 20
since_id = load('since_id')
if since_id <= 0
  since_id = nil
end
while loop_minutes > 0
  replys_to_me = twClient.mentions_timeline(count: 100,since_id: since_id)
  replys_to_me.each do |reply|
    twitter_add_log(log_csv,reply)
    if reply.user.screen_name != settings_hash['user_id']#セルフメンションは弾く
      text = slice_mention(reply.full_text.dup,reply.user_mentions[0])
      response = proto.dialogue(text)
      twClient.update('@' + reply.user.screen_name + ' '+ response,in_reply_to_status_id: reply.id)
      sleep(1)#あんまり一気に投稿すると弾かれるので休む
    end
  end
  if replys_to_me.length > 0
    settings_hash['since_id'] = replys_to_me[0].id#since_idを更新
    save_setting(settings_hash)
    save_log(log_csv)
  end
  sleep(INTERVAL_SECOND)
  proto.save()
  loop_minutes -= INTERVAL_SECOND
end