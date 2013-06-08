require "sinatra"
require "instagram"
require "raven"

require File.dirname(__FILE__) + "/weibo_worker.rb"

Instagram.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
end

get '/' do
  'Hey, girl!'
end

get '/callback' do
  request["hub.challenge"] if request["hub.verify_token"] == ENV['HUB_TOKEN']
end

post '/callback' do
  Instagram.process_subscription(request.body) do |handler|
    puts 'Incoming photo ...'
    handler.on_tag_changed do |tag_id, _|
      if tag_id == ENV['TAG']
        media_id = Instagram.tag_recent_media(tag_id, :count => 1)[0].id
        WeiboWorker.perform_async(media_id)
      end
    end
  end
  "Gocha!"
end
