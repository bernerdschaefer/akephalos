require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "akephalos"
    gem.summary = ""
    gem.description = ""
    gem.email = "bj.schaefer@gmail.com"
    gem.homepage = "http://github.com/bernerdschaefer/akephalos"
    gem.authors = ["Bernerd Schaefer"]

    gem.require_paths = ['lib', 'src']
    gem.add_dependency "capybara", '0.3.8'

    gem.add_development_dependency "sinatra"
    gem.add_development_dependency "rspec", '1.3.0'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
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

task :spec => :check_dependencies

task :default => :spec
