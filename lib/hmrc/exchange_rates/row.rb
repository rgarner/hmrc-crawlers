require 'hmrc/exchange_rates/date_range'
require 'forwardable'
require 'active_support/core_ext/string/inflections'

module Hmrc
  module ExchangeRates
    class Row
      extend Forwardable
      def_delegators :date_range, :from_date, :to_date, :type

      attr_accessor :row
      def initialize(row)
        raise ArgumentError, "expects a 3-valued row, got #{row}" unless row.length == 3
        self.row = row
      end

      def date_range
        DateRange.new(row[0])
      end

      def sterling_value
        row[1].strip
      end

      def currency_per
        row[2].strip
      end

      def to_a
        [
          type.to_s.titleize,
          date_range.format(:from_date),
          date_range.format(:to_date),
          sterling_value,
          currency_per
        ]
      end
    end
  end
end
