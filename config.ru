#!/usr/bin/env rackup
# encoding: utf-8

require File.expand_path("../boot.rb", __FILE__)

run Rack::URLMap.new({
<<<<<<< HEAD
  "/"             => BikeBook::Find
=======
  "/"          => BikeBook::Open,
  "/model_list"      => BikeBook::ModelList
>>>>>>> 983215c... Now we're rolling. Improved or creation of bike data for Trek, Fuji, Specialized, Giant, Co-Motion, KHS and Surly
})
