require 'twitter'
require 'dotenv'
require 'time'
require 'sinatra'

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

__END__

@@ index
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,user-scalable=no,maximum-scale=1">
  <title>twitterのつぶやきで生活リズムがわかる?</title>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
  <style>
  h1{ margin: 0; }
  th, td{ white-space: nowrap; }
  td:nth-of-type(1){ text-align: right; padding-right: 1em; }
  td:nth-of-type(2){ color: #5cb85c; }
  h2{ margin-bottom: 1.5em; font-size: 1em; }
  h2 span{ padding-right: 0.2em; font-size: 1.5em; font-weight: bold; color: #d9534f; }
  section{ margin-bottom: 3em; }
  footer{ text-align: center; }
  </style>
</head>
<body>
<header class="navbar navbar-default">
  <div class="container">
    <h1 class="navbar-brand">twitterで生活リズムのチェック?</h1>
  </div>
</header>
<div class="container">
  <div class="row">
    <main class="col-xs-8">
      <section>
        <h2>@で始まるtwitter名を入力してね</h2>
        <div class="form-group navbar-form">
          <div class="input-group">
            <span class="input-group-addon">@</span>
            <input type="text" id="screen_name" class="form-control" placeholder="akkagi0416">
          </div>
          <button type="submit" class="btn btn-primary">Check</button>
        </div>
      </section>
      <section id="result">
        <%= @result %>
      </section>
    </main>
    <aside class="col-xs-4">
      <img class="img-responsive" src="http://placehold.jp/150x150.png" alt="">
    </aside>
  </div>
</div>
<footer class="container">&copy; <a href="akkagi.info">akkagi</a></footer>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script> 
<script>
$(function(){
  $('button').click(function(){
    var screen_name = $('#screen_name').val();
    var request = $.ajax({
      type: "POST",
      url: "/",
      data:{ screen_name: screen_name }
    });

    request.done(function(data){
      console.log('ajax success');
      //console.log(data);
      $('#result').html(data);
    }).fail(function(e){
      console.log('ajax error');
    });
  });
});
</script>
</body>
</html>
