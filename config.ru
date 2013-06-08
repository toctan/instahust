require './web'
require 'raven'
require 'sidekiq/web'

use Raven::Rack

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
