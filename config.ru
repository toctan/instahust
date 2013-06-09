require './web'
require 'raven'
require 'sidekiq/web'

Raven.configure do |config|
  config.excluded_exceptions = ['Sinatra::NotFound']
end

use Raven::Rack

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
