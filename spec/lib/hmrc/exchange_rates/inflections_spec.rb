require 'spec_helper'
require 'active_support/core_ext/string'
require 'hmrc/exchange_rates/inflections'

describe 'This is making me mad' do
  it 'titleizes "US DOLLAR" as "US Dollar"' do
    'US DOLLAR'.titleize.should == 'US Dollar'
  end
  it 'titleizes "AUSTRIAN SCHILLING" as "Austrian Schilling" (not "A US Trian Schilling")' do
    'AUSTRIAN SCHILLING'.titleize.should == 'Austrian Schilling'
  end
end
