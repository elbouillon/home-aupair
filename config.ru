require(File.expand_path('trailblazer-config', File.dirname(__FILE__)))
require 'nylas'
require "roda"
require 'net/http'

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
  plugin :path


  # paths
  path :nylas_auth do ||
    redirect_uri = 'http://localhost:9292/nylas/register'
    response_type = 'code'
    login_hint = 'mickael@panorama-pl.ch'
    client_id = ENV['NYLAS_APP_ID']

    "https://api.nylas.com/oauth/authorize?client_id=#{client_id}&response_type=#{response_type}&scope=email&login_hint=#{login_hint}&redirect_uri=#{redirect_uri}"
  end

  route do |r|
    r.public

    # GET / request
    r.root do
      Homepage::Cell::Show.(nil, na: nylas_auth_path, session: session, layout:  Stats::Cell::Layout).()
    end

    r.get 'nylas/register' do
      code = r.params['code']
      client_id = ENV['NYLAS_APP_ID']
      client_secret = ENV['NYLAS_APP_SECRET']

      uri = URI("https://api.nylas.com/oauth/token")
      params = { client_id: client_id, client_secret: client_secret, grant_type: 'authorization_code', code: code }

      res = Net::HTTP.post_form(uri, params)
      # session[:token] = res.body['access_token']
      session[:token] = JSON.parse(res.body)['access_token']

      r.redirect '/'
    end

  end
end

run App.freeze.app
