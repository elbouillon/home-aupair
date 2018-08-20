require 'formular'

module Report
  module Cell
    class Form < Trailblazer::Cell
      include Formular::Helper
      Formular::Helper.builder= :bootstrap4

      def session
        options[:session]
      end

      def as_token
        session[:token] != nil
      end

      def api
        @api ||= Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'], access_token: session[:token])
      end

      def calendar_list
        api.calendars.map do |cal|
          [cal.name, cal.id]
        end
      end
    end
  end
end
