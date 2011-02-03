require 'rubygems'

root = File.expand_path('../../', __FILE__)
lib_paths = [root] + %w(vendor lib src).collect { |dir| File.join(root, dir) }
(lib_paths).each do |dir|
  $:.unshift dir unless $:.include?(dir)
end

require 'akephalos'

spec_dir = nil
$:.detect do |dir|
  if File.exists? File.join(dir, "capybara.rb")
    spec_dir = File.expand_path(File.join(dir,"..","spec"))
    $:.unshift( spec_dir )
  end
end

require File.join(spec_dir,"spec_helper")
require "support/application"
