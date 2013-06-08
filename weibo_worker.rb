require 'sidekiq'
require 'instagram'
require 'pony'
require 'open-uri'
require 'rest_client'
require 'raven'

class WeiboWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def initialize
    Instagram.configure do |config|
      config.client_id = ENV['CLIENT_ID']
      config.client_secret = ENV['CLIENT_SECRET']
    end
  end

  def perform(media_id)
    media = Instagram.media_item(media_id)
    image = open(media.images.standard_resolution.url)
    text = media.caption.text.gsub(/[@#]\S+\s?/, '').strip
    text = text[0..90] + '...' if text.length > 95
    author = media.user.username
    url = media.link
    weibo_status = "#{text} by #{author} ##{ENV['TAG']}# #{url}"

    RestClient.post 'https://upload.api.weibo.com/2/statuses/upload.json',
    access_token: ENV['WEIBO_ACCESS_TOKEN'], pic: image, status: weibo_status
  end

  def retries_exhausted(media_id)
    smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: ENV['GMAIL_USERNAME'],
      password: ENV['GMAIL_PASSWORD']
    }

    Pony.mail to: ENV['EXCEPTION_RECIPIENT'],
              subject: 'Instahust sync failed',
              body: media_id,
              via: :smtp,
              via_options: smtp_settings
  end
end
