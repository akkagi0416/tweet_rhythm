require 'twitter'
require 'dotenv'
require 'time'
require 'sinatra'

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

# (0..23).each do |i|
#   printf "%02d %s\n", i, "#" * tweet_counts[i] 
# end

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
