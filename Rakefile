require 'rubygems'
require 'rake'
require 'rake/clean'

JAVA = RUBY_PLATFORM == "java"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "akephalos/version"

CLEAN.include "*.gem"

task :build do
  system "gem build akephalos.gemspec"
end

task "build:java" do
  system "export PLATFORM=java && gem build akephalos.gemspec"
end

task "build:all" => ['build', 'build:java']

task :install => (JAVA ? 'build:java' : 'build') do
  gemfile = "akephalos-#{Akephalos::VERSION}#{"-java" if JAVA}.gem"
  system "gem install #{gemfile}"
end

task :release => 'build:all' do
  puts "Tagging #{Akephalos::VERSION}..."
  system "git tag -a #{Akephalos::VERSION} -m 'Tagging #{Akephalos::VERSION}'"
  puts "Pushing to Github..."
  system "git push --tags"
  puts "Pushing to Gemcutter..."
  ["", "-java"].each do |platform|
    system "gem push akephalos-#{Akephalos::VERSION}#{platform}.gem"
  end
end

load 'tasks/docs.rake'
load 'tasks/spec.rake'

task :default => :spec
