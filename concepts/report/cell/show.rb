module Report
  module Cell
    class Show < Trailblazer::Cell
      def session
        options[:session]
      end

      def eventform
        options[:eventform]
      end

      def format_hours(time_in_seconds)
        factor = time_in_seconds < 0 ? -1 : 1
        time = time_in_seconds * factor

        hours = (time/3600.00)
        minutes = ((time%3600)/60)

        formated_string = ""

        if (time_in_seconds > 0 and hours.to_i > 0) or (time_in_seconds <0)
          formated_string << "#{hours.to_i}h"
        end

        formated_string << "#{minutes}min"
        
        if factor < 0
          "-#{formated_string}"
        else
          formated_string
        end
      end
    end
  end
end
