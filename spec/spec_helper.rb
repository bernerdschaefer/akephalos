require 'rubygems'

root = File.expand_path('../../', __FILE__)
%w(vendor lib src).each do |dir|
  dir = File.join(root, dir)
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
