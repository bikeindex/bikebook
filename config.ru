#!/usr/bin/env rackup
# encoding: utf-8

require File.expand_path("../boot.rb", __FILE__)

run Rack::URLMap.new({
  "/"          => BikeBook::Open,
  "/model_list"      => BikeBook::ModelList
})
