# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "akephalos/version"

Gem::Specification.new do |s|
  s.name        = "akephalos"
  s.version     = Akephalos::VERSION
  s.platform    = ENV["PLATFORM"] || "ruby"
  s.authors     = ["Bernerd Schaefer"]
  s.email       = "bj.schaefer@gmail.com"
  s.homepage    = "http://bernerdschaefer.github.com/akephalos"
  s.summary     = "Headless Browser for Integration Testing with Capybara"
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "akephalos"

  s.add_runtime_dependency "capybara", ">= 0.4.0"

  if RUBY_PLATFORM != "java" && ENV["PLATFORM"] != "java"
    s.add_runtime_dependency "jruby-jars"
  end

  s.add_development_dependency "sinatra"
  s.add_development_dependency "rspec", ">= 2.3.0"

  s.files         = Dir.glob("lib/**/*.rb") + Dir.glob("src/**/*.jar") + %w(README.md MIT_LICENSE)
  s.require_paths = %w(lib src)
  s.executables   = %w(akephalos)
end
