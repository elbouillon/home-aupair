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
    end
  end
end
