module Hmrc
  module ExchangeRates
    class Row
      DATE_PART       = '([0-9]{2}\.[0-9]{2}\.[0-9]{2})'
      DATE_IN_REGEX   = Regexp.new("#{DATE_PART}\s+to\s+#{DATE_PART}")
      DATE_IN_FORMAT  = '%d.%m.%y'
      DATE_OUT_FORMAT = '%Y-%m-%d'

      attr_accessor :row, :from_date_str, :to_date_str
      def initialize(row)
        raise ArgumentError, 'expects a 3-valued row' unless row.length == 3
        self.row = row

        DATE_IN_REGEX     =~ row[0]
        self.from_date_str = $1
        self.to_date_str   = $2 || row[0]
      end

      def from_date
        @_from_date ||= if from_date_str
          Date.strptime(from_date_str, DATE_IN_FORMAT)
        else
          Date.new(to_date.year - 1, to_date.month, to_date.day)
        end
      end

      def to_date
        @_to_date ||= Date.strptime(to_date_str, DATE_IN_FORMAT)
      end

      def sterling_value
        row[1]
      end

      def currency_per
        row[2]
      end

      def to_a
        [
          output_date,
          sterling_value,
          currency_per
        ]
      end

      def output_date
        dates = from_date_str ? [:from_date, :to_date] : [:to_date]
        dates.map {|d| (send d).strftime(DATE_OUT_FORMAT) }.join(' to ')
      end
    end
  end
end
