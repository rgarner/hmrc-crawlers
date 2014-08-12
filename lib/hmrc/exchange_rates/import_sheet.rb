require 'json'

module Hmrc
  module ExchangeRates
    class ImportSheet
      FILENAME = 'results/_import.csv'

      HEADER = [
        'old_url',
        'title',
        'summary',
        'body',
        'organisation',
        'document_collection_1',
        'topic_1',
        'publication_date',
        'publication_type',
        'json_attachments'
      ]

      def header
        HEADER
      end

      def rows
        @rows ||= []
      end

      def add_country(url, country)
        rows << [
          url,
          country.document.title,
          country.document.summary,
          country.document.body,
          'hm-revenue-customs',
          'hmrc-exchange-rates',
          'tax-and-revenue',
          country.issued.strftime('%d-%b-%Y'),
          '',
          JSON.dump([
            {
              title: country.document.title,
              link: "https://raw.githubusercontent.com/rgarner/hmrc-crawlers/master/results/#{country.basename}.csv"
            }
          ])
        ]
      end

      def to_csv
        CSV.generate do |csv|
          csv << HEADER
          rows.each do |row|
            csv << row
          end
        end
      end

      def save!(filename = FILENAME)
        File.open(filename, 'w') do |f|
          f.write(to_csv)
        end
      end
    end
  end
end
