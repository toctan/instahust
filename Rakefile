require 'instagram'

require File.dirname(__FILE__) + "/weibo_worker.rb"

task :configure do
  Instagram.configure do |config|
    config.client_id = ENV['CLIENT_ID']
    config.client_secret = ENV['CLIENT_SECRET']
  end
end

desc "List all subscriptions"
task :subs => :configure do
  Instagram.subscriptions.each do |sub|
    p sub
  end
end

desc "Create a Instagram tag subscription"
task :create_sub => :configure do
  Instagram.create_subscription("tag", "http://#{ENV['DOMAIN']}/callback",
                                object_id: ENV['TAG'], verify_token: ENV['HUB_TOKEN'])
  puts "Subscription created: #{ENV['TAG']}"
end

desc "Delete a Instagram tag subscription"
task :delete_sub => :configure do
  Instagram.delete_subscription(object: "tag", object_id: ENV['TAG'])
  puts "Subscription deleted: #{ENV['TAG']}"
end

desc "Resubscribe to the tag"
task :resub => [:delete_sub, :create_sub] do
  puts 'Subscription recreated.'
end

desc "Resync the photo if the sync fails"
task :resync do
  mid = ENV['LINK'] ? Instagram.oembed(ENV['LINK']).media_id : ENV['MEDIA_ID']
  WeiboWorker.perform_async mid unless mid.nil?
end
