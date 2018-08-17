module Homepage
  module Cell
    class Show < Trailblazer::Cell
      def na
        options[:na]
      end

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
          {cal.id.to_sym => cal.name}
        end
      end
    end
  end
end
