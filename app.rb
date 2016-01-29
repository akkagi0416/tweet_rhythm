require 'twitter'
require 'dotenv'
require 'time'

Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_SECRET"]
end

tweets = client.user_timeline("akkagi0416", { count: 200 } )

tweet_counts = []
(0..23).each {|i| tweet_counts[i] = 0 }

tweets.each do |tweet|
  tweet_counts[tweet.created_at.getlocal.hour] += 1 # 日本時間に変更
end

(0..23).each do |i|
  printf "%02d %s\n", i, "#" * tweet_counts[i] 
end

