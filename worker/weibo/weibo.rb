require 'open-uri'
require 'rest_client'

class Weibo
  def initialize(media_id)
    @media_id = media_id
  end

  def post
    return if recent_media_ids.include? @media_id
    puts "Syncing #{media.link} : #{@media_id}"

    cache_media_id

    begin
      RestClient.post 'https://upload.api.weibo.com/2/statuses/upload.json',
                      access_token: CONF['weibo']['access_token'],
                      status: status,
                      pic: image
    rescue
      uncache_media_id
      raise
    end
  end

  private

  def recent_media_ids
    REDIS.lrange('media_ids', 0, -1)
  end

  def cache_media_id
    REDIS.multi do
      REDIS.lpush('media_ids', @media_id)
      REDIS.ltrim('media_ids', 0, 99)
    end
  end

  def uncache_media_id
    REDIS.lpop 'media_ids'
  end

  def media
    @media ||= Instagram.media_item @media_id
  end

  def image
    @image ||= open(media.images.standard_resolution.url)
  end

  def status
    "#{formatted_text} (by #{media.user.username}) #instahust# #{media.link}"
  end

  def formatted_text
    return if media.caption.nil?
    text = media.caption.text.gsub(/[@#]\S+\s?/, '').strip
    text.length > 95 ? "#{text[0..90]} ..." : text
  end
end
