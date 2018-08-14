require(File.expand_path('trailblazer-config', File.dirname(__FILE__)))
require "roda"

class App < Roda
  plugin :default_headers,
    'Content-Type'=>'text/html',
    # 'Content-Security-Policy'=>"default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block',
    'Accept-Charset'=>'utf-8'

  use Rack::Session::Cookie,
    :key => '_Homeaupair_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    :secret=> ENV['SESSION_SECRET']

  plugin :public

  route do |r|
    r.public

    # GET / request
    r.root do
      Homepage::Cell::Show.(nil, layout:  Stats::Cell::Layout).()
    end

  end
end

run App.freeze.app
