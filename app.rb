require 'rubygems'
require 'twitter'
require 'dotenv'
require 'time'
require 'sinatra/base'

Dotenv.load # twitter認証key取得

class App
  attr_reader :screen_name
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_SECRET"]
    end
    @screen_name  = nil
    @tweet_counts = Array.new(24, 0)
  end

  def get_tweet_counts(screen_name = 'akkagi0416')
    @screen_name = screen_name
    @tweet_counts = Array.new(24, 0)

    tweets = @client.user_timeline(@screen_name, { count: 200 } )
    tweets.each do |tweet|
      @tweet_counts[tweet.created_at.getlocal.hour] += 1 # 日本時間に変更
    end
    @tweet_counts.map {|count| count.to_f / tweets.count * 100 }
  end

  def make_result
    html = "<h2><span>@#{@screen_name}</span>さんのtweet頻度</h2>"
    html += '<table>
      <tr><th>時間</th><th>tweet頻度</th></tr>'
    (0..23).each do |i|
      html += "<tr><td>#{i}時</td><td>" + "#" * @tweet_counts[i] + "</td></tr>"
    end
    html += "</table>"
    html
  end
end

app = App.new
# p app.get_tweet_counts

# Web part
get '/' do
  app.get_tweet_counts  # akkagi0416(default)
  @result = app.make_result
  erb :index
end

post '/' do
  # @tweet_counts = app.get_tweet_counts(params['screen_name'])
  # make_result(@tweet_counts)
  begin
    app.get_tweet_counts(params['screen_name'])
    app.make_result
  rescue Twitter::Error::NotFound
    "<h2><span>@#{app.screen_name}</span>さんは見つかりませんでした</h2>"
  end
end

