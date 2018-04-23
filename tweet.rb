# coding: utf-8
#TwitterAPI経由でRubyからツイートするスクリプト

#= TwitterとNORの橋渡しをするクラス
=begin
Schedulerで実行するファイルでもある
=end

require 'twitter'
require 'active_support'
require 'active_support/core_ext'
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

#== メソッドが使いたいので一応クラスを定義する
class Tweet
#== 各種値をdatabaseから引っ張ってくる(クラスメソッド)
=begin
key キーの名前(ex:since_id(String)
value 値(Integer)
=end
  def self.load(key)
    if Param.find(key)
      return Param.find(key).value
    end
  end

#== 各種値をdatabaseに保存する(クラスメソッド)
=begin
key キーの名前(ex:since_id(String)
value 値(Integer)
=end
  def self.save(key,value)
    if Param.find(key)
      Param.find(key).update_attribute(:value,value)
    end
  end

#== 最初の@メンションを切り取る(クラスメソッド)
  def self.slice_mention(text,mention)
    if mention != nil
      num = mention.indices[1]-mention.indices[0]
      text.slice!(mention.indices[0],num)
    end
    return text
  end

  #== ログイン時にする処理
  def twitter_login()
  
  end

  #== ログアウト時にする処理
  def twitter_logout()
  
  end
end

#== 直接実行時限定の処理
if __FILE__ == $0
  #クライアントを作成
  #セキュリティのため環境変数で設定してね
  twClient = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token    = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  #人工無脳本体を作成
  user_id = Tweet.load('user_id')
  proto = Nor.new(user_id)
  
  # 1回の実行につき継続して動かしたい時間の間だけループする
  # TwitterAPIの制限に引っかからない程度にツイートを取得する間隔(秒)
  loop_minutes = Tweet.load('loop_minutes').to_i*60
  INTERVAL_SECOND = 20
  since_id = Tweet.load('since_id')
  if since_id.to_i <= 0
    since_id = nil
  end
  
  while loop_minutes > 0
    replys_to_me = twClient.mentions_timeline(count: 100,since_id: since_id.to_i)
    replys_to_me.each do |reply|
      if reply.user.screen_name != user_id#セルフメンションは弾く
        text = slice_mention(reply.full_text.dup,reply.user_mentions[0])
        response = proto.dialogue(text)
        twClient.update('@' + reply.user.screen_name + ' '+ response,in_reply_to_status_id: reply.id)
        sleep(1)#あんまり一気に投稿すると弾かれるので休む
      end
    end
    if replys_to_me.length > 0
      since_id = replys_to_me[0].id.to_s#since_idを更新
    end
    sleep(INTERVAL_SECOND)
    loop_minutes -= INTERVAL_SECOND
  end
  Tweet.save('since_id',since_id)
end