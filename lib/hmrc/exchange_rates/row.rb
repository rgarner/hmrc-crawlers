require 'hmrc/exchange_rates/date_range'
require 'forwardable'
require 'active_support/core_ext/string/inflections'

module Hmrc
  module ExchangeRates
    class Row
      extend Forwardable
      def_delegators :date_range, :from_date, :to_date, :type

      attr_accessor :row, :country

      def initialize(row, country)
        raise ArgumentError, "expects a 3-valued row, got #{row}" unless row.length == 3
        self.row     = row
        self.country = country
      end

      def date_range
        @_date_range = DateRange.new(row[0])
      end

      def sterling_value
        @_sterling_value = strip_unwanted(row[1])
      end

      def currency_per
        @_currency_per = strip_unwanted(row[2])
      end

      def ecu?
        @_ecu = [row[1], row[2]].find {|s| s.include?('(ECU)')}
      end

      def to_a
        [
          type.to_s.titleize,
          date_range.format(:from_date),
          date_range.format(:to_date),
          sterling_value,
          currency_per,
          case
          when ecu?
            'ECU'
          when country.euro_date.nil? || date_range.to_date < country.euro_date
            country.currency
          else
            'Euro'
          end
        ]
      end

    private
      UNWANTED = /\((ECU|Euro)\)/

      def strip_unwanted(value)
        value.sub(UNWANTED, '').strip
      end
    end

  end
end
