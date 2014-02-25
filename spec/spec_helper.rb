require "simplecov"
SimpleCov.start

ENV['RACK_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../boot")

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
