require 'rubygems'
require 'rake'

JAVA = RUBY_PLATFORM == "java"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "akephalos/version"

task :build do
  system "gem build akephalos.gemspec"
end

task "build:java" do
  system "export PLATFORM=java && gem build akephalos.gemspec"
end

task :build_all => ['build', 'build:java']

task :install => (JAVA ? 'build:java' : 'build') do
  gemfile = "akephalos-#{Akephalos::VERSION}#{"-java" if JAVA}.gem"
  system "gem install #{gemfile}"
end

task :release => :build_all do
  puts "Tagging #{Akephalos::VERSION}..."
  system "git tag -a #{Akephalos::VERSION} -m 'Tagging #{Akephalos::VERSION}'"
  puts "Pushing to Github..."
  system "git push --tags"
  puts "Pushing to Gemcutter..."
  ["", "-java"].each do |platform|
    system "gem push akephalos-#{Akephalos::VERSION}#{platform}.gem"
  end
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec
task :default => :spec
