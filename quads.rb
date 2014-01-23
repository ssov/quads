#!/usr/bin/env ruby

require_relative './lib/quads.rb'
require 'optparse'

include Quads

OptionParser.new do |opt|
  opt.on('-c CSV') {|v| @csv = v }
  opt.on('-m Major') {|v| @major = v }
  opt.parse!(ARGV)
end

@quads = Quads::Quads.new(csv: @csv, major: @major)
@quads.print
