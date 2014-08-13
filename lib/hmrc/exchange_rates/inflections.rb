require 'active_support/inflector'

module ActiveSupport
  module Inflector
    def our_titleize(str)
      activesupport_titleize(str).gsub(/^us /i, 'US ')
    end

    alias_method :activesupport_titleize, :titleize
    alias_method :titleize, :our_titleize
  end
end
