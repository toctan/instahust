require './web'

require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
