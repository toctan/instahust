require 'instagram'

task :configure do
  Instagram.configure do |config|
    config.client_id = ENV['CLIENT_ID']
    config.client_secret = ENV['CLIENT_SECRET']
  end
end

task :subs => :configure do
  Instagram.subscriptions.each do |sub|
    p sub
  end
end

task :create_sub => :configure do
  Instagram.create_subscription("tag", "http://#{ENV['DOMAIN']}/callback",
                                object_id: ENV['TAG'])
  puts "Subscription created: #{ENV['TAG']}"
end

task :delete_sub => :configure do
  Instagram.delete_subscription(object: "tag", object_id: ENV['TAG'])
  puts "Subscription deleted: #{ENV['TAG']}"
end

task :resub => [:delete_sub, :create_sub] do
  puts 'Subscription recreated.'
end
