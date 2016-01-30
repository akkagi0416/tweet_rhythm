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
    tweets = @client.user_timeline(@screen_name, { count: 200 } )
    tweets.each do |tweet|
      @tweet_counts[tweet.created_at.getlocal.hour] += 1 # 日本時間に変更
    end
    @tweet_counts
  end

  # tweet_counts = []
  # (0..23).each {|i| tweet_counts[i] = 0 }

  # tweets.each do |tweet|
  #   tweet_counts[tweet.created_at.getlocal.hour] += 1 # 日本時間に変更
  # end

  # (0..23).each do |i|
  #   printf "%02d %s\n", i, "#" * tweet_counts[i] 
  # end
end

app = App.new
p app.get_tweet_counts

# Web part
get '/' do
  @tweet_counts = tweet_counts
  erb :index
end

post '/' do
  params['screen_name']
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
    <table>
      <tr><th>時間</th><th>tweet回数</th></tr>
      <% (0..23).each do |i| %>
        <tr>
          <td><%= i %></td>
          <td><%= "#" * @tweet_counts[i] %></td>
        </tr>
      <% end %>
    </table>
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
      console.log(data);
      $('#result').html('<p>' + data + '</p>');
    }).fail(function(e){
      console.log('ajax error');
    });
  });
});
</script>
</body>
</html>
