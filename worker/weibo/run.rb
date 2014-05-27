require 'yaml'
require 'redis'
require 'instagram'

require './weibo'

CONF = YAML.load_file('config.yml')

REDIS = Redis.new(url: CONF['redis_to_go'])

Instagram.configure do |config|
  config.client_id = CONF['instagram']['client_id']
  config.client_secret = CONF['instagram']['client_secret']
end

Array(params[:media_ids]).each do |media_id|
  Weibo.new(media_id).post
end
