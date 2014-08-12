module Hmrc
  module ExchangeRates
    class DateRange
      DATE_IN_FORMAT    = '%d.%m.%y'
      DATE_SLASH_FORMAT = '%d/%m/%y'
      DATE_OUT_FORMAT   = '%Y-%m-%d'

      DATE_PART      = '([0-9]{1,2}\.\s*?[0-9]{1,2}\.\s*?[0-9]{1,2})'
      SLASH_DATE     = '([0-9]{1,2}/[0-9]{1,2}/[0-9]{1,2})'
      SIMPLE_DATE    = Regexp.new(DATE_PART)
      SIMPLE_RANGE   = Regexp.new("#{DATE_PART}\s+to\s+#{DATE_PART}")
      SIMPLE_AVERAGE = Regexp.new("Average for year to #{DATE_PART}")
      SLASH_RANGE    = Regexp.new("Average for #{SLASH_DATE}\s?-\s?#{SLASH_DATE}")
      AVERAGE_RANGE  = Regexp.new("Average #{DATE_PART}\s+to\s+#{DATE_PART}")
      NO_DAY_RANGE   = Regexp.new('Average for ([0-9]{1,2}\.[0-9]{1,2}) to ([0-9]{1,2}\.[0-9]{1,2})')
      SPOT_DATE      = Regexp.new("Spot rate on #{DATE_PART}")
      EURO_RANGE     = Regexp.new("Euro from #{DATE_PART}\s+to\s+#{DATE_PART}")

      DATE_CORRECTIONS = {
        '31.09.91' => '30.09.91',
        '31.13.06' => '31.12.06'
      }

      attr_accessor :input
      def initialize(input)
        self.input = input
        @slash_date = false
        normalized_date_strings
      end

      def type
        @type || :average_for_year_to
      end

      def zero_fill(str)
        return nil if str.nil?
        str.gsub(' ', '0')
      end

      ##
      # Given a string like 01.02 and a start or end, give a normalized
      # date string, e.g.
      #
      # +snap_date('01.02', :end) => '31.01.02'+ or
      # +snap_date('01.02', :start) => '01.01.02'+
      def snap_date(str, start_or_end)
        day = (start_or_end == :start) ? 1 : -1
        month, year = *(str.split('.').map(&:to_i))

        Date.new(year, month, day).strftime(DATE_IN_FORMAT)
      end

      ##
      # Normalize to HMRC usual of DD.MM.YY
      def normalized_date_strings
        @_normalized_date_strings ||= case input
                                      when AVERAGE_RANGE, EURO_RANGE
                                        [zero_fill($1), zero_fill($2)]
                                      when SLASH_RANGE
                                        @slash_date = true
                                        [zero_fill($1), zero_fill($2)]
                                      when SIMPLE_RANGE
                                        [zero_fill($1), zero_fill($2)]
                                      when SIMPLE_AVERAGE
                                        [nil, zero_fill($1)]
                                      when SPOT_DATE
                                        @type = :spot
                                        [nil, zero_fill($1)]
                                      when SIMPLE_DATE
                                        [nil, zero_fill($1)]
                                      when NO_DAY_RANGE
                                        [snap_date($1, :start), snap_date($2, :end)]
                                      else
                                        raise ArgumentError, "unrecognised format: #{input.class} '#{input}'"
                                      end
      end

      def from_date_str
        normalized_date_strings[0]
      end

      def to_date_str
        normalized_date_strings[1]
      end

      def date_in_format
        @slash_date ? DATE_SLASH_FORMAT : DATE_IN_FORMAT
      end

      def parse_date(str)
        str = DATE_CORRECTIONS[str] || str
        Date.strptime(str, date_in_format)
      rescue
        raise ArgumentError, "parse_date failed - #{to_date_str.class} #{to_date_str}"
      end

      def from_date
        @_from_date ||= if from_date_str
          parse_date(from_date_str)
        else
          Date.new(to_date.year - 1, to_date.month, to_date.day) unless type == :spot
        end
      end

      def to_date
        @_to_date ||= parse_date(to_date_str)
      end

      def format(date_sym)
        date_value = (send date_sym)
        date_value && date_value.strftime(DATE_OUT_FORMAT)
      end

      def to_s
        dates = from_date_str && !@spot_date ? [:from_date, :to_date] : [:to_date]
        dates.map { |date| format(date) }.join(' to ')
      end
    end
  end
end
