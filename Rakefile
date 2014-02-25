task :default => :help

desc "Open console in app environment"
task :console do
  system("irb -r ./config/boot.rb")
end

desc "create BikeBook directories"
task :refresh do 
  require File.expand_path(File.dirname(__FILE__) + "/boot.rb")
  BikeBook::BookGenerator.new.refresh
end


begin
  require 'rspec/core/rake_task'
  desc "Run specs"
  task :spec do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = './spec/**/*_spec.rb'
    end
  end
rescue LoadError
end