require 'sidekiq'
require 'weibo_2'
require 'instagram'

class WeiboWorker
  include Sidekiq::Worker

  def initialize
    Instagram.configure do |config|
      config.client_id = ENV['CLIENT_ID']
      config.client_secret = ENV['CLIENT_SECRET']
    end

    WeiboOAuth2::Config.api_key = ENV['WEIBO_KEY']
    WeiboOAuth2::Config.api_secret = ENV['WEIBO_SECRET']
  end

  def perform(tag_id)
    medium = Instagram.tag_recent_media(tag_id, :count => 1)
    image_url = medium[0].images.standard_resolution.url
    text = medium[0].caption.text
    author = medium[0].user.username
    url = medium[0].link
    weibo_status = "##{tag_id}# #{text} (by #{author}) #{url}"

    client = WeiboOAuth2::Client.new.access_token = ENV['WEIBO_ACCESS_TOKEN']
    client.statuses.upload_url_text({ status: weibo_status, url: image_url })
  end
end
