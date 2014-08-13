require 'hmrc/exchange_rates/inflections'
require 'hmrc/exchange_rates/country'
require 'hmrc/exchange_rates/import_sheet'

module Hmrc
  module ExchangeRates
    BASE_URL = 'http://www.hmrc.gov.uk/exrate'
    INDEX_PAGE = /index\.htm\/?$/
  end
end
