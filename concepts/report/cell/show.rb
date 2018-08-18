module Report
  module Cell
    class Show < Trailblazer::Cell
      def session
        options[:session]
      end

      def eventform
        options[:eventform]
      end
    end
  end
end
