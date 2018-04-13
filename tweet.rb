# coding: utf-8

require 'twitter'

class Tweet

  def initialize
    @text = ["ちゃうねん",
             "せやないねん",
             "どないやねん",
             "ええねん",
             "これや!!",
             "いけるで!!",
             "こっからや!!"]

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'ubheEzBUGwJLBCKzU5Y8UE95G'
      config.consumer_secret     = 'kMimqFlRBcXAgKfB42ckoqIslZfh0vmAfpXcsMihvPpEWNo934'
      config.access_token        = '981527887932153857-Bq0S2s5DYkrVDNgcVUmccb2KM2rEKSm'
      config.access_token_secret = 'wXkPq1VmRdYRWdyg52fIMks8lwHdLxDGpK7jdpUUtoqOL'
    end
  end

  def random_tweet
    tweet = @text[rand(@text.length)]
    update(tweet)
  end

  private

   def update(tweet) 
     begin
       @client.update(tweet)
     rescue => e
       nil #TODO
     end
   end

end

# random_tweetを実行する
if __FILE__ == $0
  Tweet.new.random_tweet
end