require 'sinatra'
require './app.rb'

map '/rhythm' do
  run Sinatra::Application
end

# run Sinatra::Application
