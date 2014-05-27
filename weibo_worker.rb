require 'sidekiq'
require 'instagram'
require 'pony'
require 'open-uri'
require 'rest_client'

class WeiboWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 10

  def initialize
    Instagram.configure do |config|
      config.client_id = ENV['CLIENT_ID']
      config.client_secret = ENV['CLIENT_SECRET']
    end
  end

  def perform(media_id)
    media = Instagram.media_item(media_id)
    image = open(media.images.standard_resolution.url)
    post_to_weibo(image, build_weibo_status(media))
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

  private
  def build_weibo_status(media)
    "#{format_media_text(media)} by #{media.user.username} "\
    "##{ENV['TAG']}# #{media.link}"
  end

  def format_media_text(media)
    return if media.caption.nil?
    text = media.caption.text.gsub(/[@#]\S+\s?/, '').strip
    text.length > 95 ? "#{text[0..90]} ..." : text
  end

  def post_to_weibo(image, status)
    RestClient.post 'https://upload.api.weibo.com/2/statuses/upload.json',
    access_token: ENV['WEIBO_ACCESS_TOKEN'], pic: image, status: status
  end
end
