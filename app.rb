require 'twitter'
require 'dotenv'
require 'time'
require 'sinatra'

Dotenv.load

class App
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
end

def make_result(tweet_counts)
  html = 
  # '<table>
  #   <tr><th>時間</th><th>tweet回数</th></tr>'
  # (0..23).each do |i|
  #   html += "<tr><td>#{i}時</td><td>" + "#" * tweet_counts[i] + "</td></tr>"
  # end
  # html += "</table>"
  '<dl>'
  (0..23).each do |i|
    html += "<dt>#{i}時</dt><dd>"
    html += "<div class='progress'>
      <div class='progress-bar progress-bar-success' role='progressbar' aria-valuenow='#{tweet_counts[i]}' aria-valuemin='0' aria-valuemax='100' style='width: #{tweet_counts[i]}%'>
        <span class='sr-only'>#{tweet_counts[i]}%</span>
      </div>
    </div>"
    html += "</dd>"
  end
  html += '</dl>'
  html
end

app = App.new
p app.get_tweet_counts

# Web part
get '/' do
  @result = make_result(app.get_tweet_counts)
  erb :index
end

post '/' do
  @tweet_counts = app.get_tweet_counts(params['screen_name'])
  make_result(@tweet_counts)
end

__END__

@@ index
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>twitterのつぶやきで生活リズムがわかる?</title>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
  <style>
  h1{ margin: 0; }
  dt, dd{ float: left; }
  dt{ width: 20%; clear: both; text-align: right; padding-right: 1em; }
  dd{ width: 70%; height: 1.6em; }
  </style>
</head>
<body>
<header class="navbar navbar-default">
  <div class="container">
    <h1 class="navbar-brand">twitterで生活リズム?</h1>
  </div>
</header>
<div class="container">
  <div class="form-group navbar-form">
    <div class="input-group">
      <span class="input-group-addon">@</span>
      <input type="text" id="screen_name" class="form-control" placeholder="akkagi0416">
    </div>
    <button type="submit" class="btn btn-primary">Check</button>
  </div>
  <div id="result">
  <%= @result %>
  </div>
</div>
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
