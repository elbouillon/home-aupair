require(File.expand_path('trailblazer-config', File.dirname(__FILE__)))
require 'nylas'
require "roda"
require 'net/http'

class App < Roda
  plugin :default_headers,
    'Content-Type'=>'text/html',
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block',
    'Accept-Charset'=>'utf-8'

  use Rack::Session::Cookie,
    :key => '_Homeaupair_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    :secret=> ENV['SESSION_SECRET']

  plugin :public, gzip: true
  plugin :path


  # paths
  path :nylas_auth do ||
    redirect_uri = 'http://localhost:9292/nylas/register'
    response_type = 'code'
    # login_hint = 'mickael@panorama-pl.ch'
    login_hint = ''
    client_id = ENV['NYLAS_APP_ID']

    "https://api.nylas.com/oauth/authorize?client_id=#{client_id}&response_type=#{response_type}&scope=email&login_hint=#{login_hint}&redirect_uri=#{redirect_uri}"
  end

  route do |r|
    r.public

    # GET / request
    r.root do
      eventForm = Struct.new(:calendar_id, :from, :to)
      model = eventForm.new(nil, Date.today-5, Date.today)
      Homepage::Cell::Show.(model, na: nylas_auth_path, session: session, layout:  Stats::Cell::Layout).()
    end

    r.get 'logout' do
      session.clear
      r.redirect '/'
    end

    r.on 'nylas' do

      r.post 'events' do
        api = Nylas::API.new(
          app_id: ENV['NYLAS_APP_ID'],
          app_secret: ENV['NYLAS_APP_SECRET'],
          access_token: session[:token]
        )

        cal_id = r.params['calendar_id']
        from = Date.parse(r.params['from']).to_time
        to = Date.parse(r.params['to']).to_time

        day = 60*60*24

        events = api.events.where(
          calendar_id: cal_id,
          starts_after: from.to_i - day,
          ends_before: to.to_i + day
        ).execute

        e = []
        (from.to_date..to.to_date).each do |day|
          e << { 
            day: day, 
            events: events.select{ 
              |event| Nylas::Event.new(event).when.start_time.to_date == day 
            }.map{|e| Nylas::Event.new(e)}
          }
        end
        # supprimer les jours vides
        e.select! { |day| day[:events].count > 0 }

        eventForm = Struct.new(:calendar_id, :from, :to)
        model = eventForm.new(cal_id, from.to_date, to.to_date)
        
        Report::Cell::Show.(e, session: session, eventform: model, layout: Stats::Cell::Layout).()
      end

      r.get 'register' do
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
end

run App.freeze.app
