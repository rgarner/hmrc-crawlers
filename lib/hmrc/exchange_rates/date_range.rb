module Hmrc
  module ExchangeRates
    class DateRange
      DATE_IN_FORMAT  = '%d.%m.%y'
      DATE_OUT_FORMAT = '%Y-%m-%d'

      DATE_PART      = '([0-9]{1,2}\.\s*?[0-9]{1,2}\.\s*?[0-9]{1,2})'
      SIMPLE_DATE    = Regexp.new(DATE_PART)
      SIMPLE_RANGE   = Regexp.new("#{DATE_PART}\s+to\s+#{DATE_PART}")
      SIMPLE_AVERAGE = Regexp.new("Average for year to #{DATE_PART}")
      AVERAGE_RANGE  = Regexp.new("Average #{DATE_PART}\s+to\s+#{DATE_PART}")
      SPOT_DATE      = Regexp.new("Spot rate on #{DATE_PART}")
      EURO_RANGE     = Regexp.new("Euro from #{DATE_PART}\s+to\s+#{DATE_PART}")

      attr_accessor :input
      def initialize(input)
        self.input = input
        @spot_date = false
      end

      def zero_fill(str)
        return nil if str.nil?
        str.gsub(' ', '0')
      end

      def normalized_date_strings
        @_normalized_date_strings ||= case input
                                      when AVERAGE_RANGE, EURO_RANGE
                                        [zero_fill($1), zero_fill($2)]
                                      when SIMPLE_RANGE
                                        [$1, $2]
                                      when SIMPLE_AVERAGE
                                        [nil, zero_fill($1)]
                                      when SPOT_DATE
                                        @spot_date = true
                                        [nil, zero_fill($1)]
                                      when SIMPLE_DATE
                                        [nil, $1]
                                      else
                                        raise ArgumentError, 'unrecognised format'
                                      end
      end

      def from_date_str
        normalized_date_strings[0]
      end

      def to_date_str
        normalized_date_strings[1]
      end

      def from_date
        @_from_date ||= if from_date_str
          Date.strptime(from_date_str, DATE_IN_FORMAT)
        else
          Date.new(to_date.year - 1, to_date.month, to_date.day) unless @spot_date
        end
      end

      def to_date
        begin
          @_to_date ||= Date.strptime(to_date_str, DATE_IN_FORMAT)
        rescue
          raise ArgumentError, "strptime failed - #{to_date_str.class} #{to_date_str}"
        end
      end

      def to_s
        dates = from_date_str && !@spot_date ? [:from_date, :to_date] : [:to_date]
        dates.map {|d| (send d).strftime(DATE_OUT_FORMAT) rescue 'foo' }.join(' to ')
      end

      def self.parse(str)
        DateRange.new(str)
      end
    end
  end
end
