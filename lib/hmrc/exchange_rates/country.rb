require 'csv/table'

module Hmrc
  module ExchangeRates
    class Country
      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end

      def table
        @_table ||= Csv::Table.from_html(doc.at_css('#centre_col table'))
      end

      def name
        @_name ||= begin
          /exchange rates:.*\n\s+(?<parsed_name>.*)\n/m =~ doc.at_css('#centre_col > h1').text
          parsed_name
        end
      end

      def currency
        @_currency ||= begin
          /:\s+(?<currency_name>.*)$/ =~ table.caption
          currency_name.split(' ').map(&:capitalize).join(' ')
        end
      end

      def transformed_rows
        table.rows.map do |row|
          date_parts = row[0].split('.')
          transformed_date = "20#{date_parts[2]}-#{date_parts[1]}-#{date_parts[0]}"
          [transformed_date].concat(row[1..-1])
        end
      end

      def csv
        [table.header].concat(transformed_rows)
      end

      def self.parse(doc)
        raise ArgumentError, 'Country.parse requires an HTML document' \
          unless doc.kind_of?(Nokogiri::HTML::Document)

        Country.new(doc)
      end
    end
  end
end