#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'anemone'
require 'hmrc/exchange_rates'

def create_or_update_content_for(page)
  country       = Hmrc::ExchangeRates::Country.new(page.doc)
  base_filename = File.join('results', File.basename(page.url.to_s, 'htm'))

  File.open(base_filename + 'csv', 'w') do |f|
    f.write(country.to_csv)
  end
  File.open(base_filename + 'md',  'w') do |f|
    f.write(country.document.body)
  end
end

FileUtils.mkdir_p('results')

Anemone.crawl(File.join(Hmrc::ExchangeRates::BASE_URL, 'index.htm')) do |crawl|
  crawl.on_every_page do |page|
    puts page.url
    create_or_update_content_for(page) unless page.url.to_s =~ Hmrc::ExchangeRates::INDEX_PAGE
  end

  crawl.focus_crawl do |page|
    page.doc.css('#country option').map do |option|
      URI(File.join(Hmrc::ExchangeRates::BASE_URL, option['value']))
    end
  end
end
