require 'hmrc/exchange_rates/country'
require 'kramdown'

module Hmrc
  module ExchangeRates
    class Country
      class Document
        attr_reader :country
        def initialize(country)
          raise ArgumentError, 'requires a country' unless country.is_a?(Hmrc::ExchangeRates::Country)
          @country = country
        end

        def title
          "Foreign Exchange Rates: #{country.name}"
        end

        def summary
          "Historical exchange rates for #{country.name}"
        end

        def extra_markdown
          @_extra_markdown ||= country.extra_markup && Kramdown::Document.new(
            country.extra_markup,
            input: 'html'
          ).to_kramdown.gsub(/\{:.+?}/m, '')
        end

        def body
          <<-MARKDOWN
# #{title}

## Unit of currency: #{country.currency}

#{extra_markdown}
          MARKDOWN
        end
      end
    end
  end
end
