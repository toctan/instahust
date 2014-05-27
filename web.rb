require 'redis'
require 'sinatra'
require 'instagram'
require 'iron_worker_ng'

$redis = Redis.new(url: ENV['REDISTOGO_URL'])

Instagram.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
end

def process_sub(req_body, signature)
  fail Instagram::InvalidSignature unless signature

  Instagram.process_subscription(req_body, signature: signature) do |handler|
    handler.on_tag_changed do |tag_id, _|
      return if tag_id != ENV['TAG']
      medias = Instagram.tag_recent_media(tag_id, min_tag_id: $redis.get('min_tag_id'))
      IronWorkerNG::Client.new.tasks.create('weibo', media_ids: medias.map(&:id))
      min_tag_id = medias.pagination[:min_tag_id]
      $redis.set('min_tag_id', min_tag_id) if min_tag_id
      puts "min_tag_id: #{min_tag_id}"
    end
  end
end

get '/' do
  'Hey, girl!'
end

get '/callback' do
  request['hub.challenge'] if request['hub.verify_token'] == ENV['HUB_TOKEN']
end

post '/callback' do
  begin
    process_sub(request.body.read, env['HTTP_X_HUB_SIGNATURE'])
  rescue Instagram::InvalidSignature
    halt 403
  end
  'Gocha!'
end
