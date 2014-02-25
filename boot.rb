ENV["RACK_ENV"] ||= "development"

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"].to_sym)
require 'yaml'
require 'active_support/all'

Dir["./lib/**/*.rb"].each { |f| require f }