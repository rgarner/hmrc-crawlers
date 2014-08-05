module Hmrc
  module ExchangeRates
    class Row
      DATE_IN_FORMAT  = '%d.%m.%y'
      DATE_OUT_FORMAT = '%Y-%m-%d'

      attr_reader :row
      def initialize(row)
        raise ArgumentError, 'expects a 3-valued row' unless row.length == 3
        @row = row
      end

      def from_date
        @_from_date ||= Date.new(to_date.year - 1, to_date.month, to_date.day)
      end

      def to_date
        @_to_date ||= Date.strptime(row[0], DATE_IN_FORMAT)
      end

      def sterling_value
        row[1]
      end

      def currency_per
        row[2]
      end

      def to_a
        [
          to_date.strftime(DATE_OUT_FORMAT),
          sterling_value,
          currency_per
        ]
      end
    end
  end
end
