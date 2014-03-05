#!/usr/bin/env ruby

require_relative './lib/quads.rb'
require 'optparse'

include Quads

major = {
  "ソフトウェアサイエンス" => 2,
  "情報システム" => 3,
  "知能情報メディア" => 4
}

OptionParser.new do |opt|
  opt.on('-c CSV') {|v| @csv = v }
  opt.on('-m Major') {|v| @major = v }
  opt.on('--login') {|v|
    Twins.login
    @major = major[Twins.get_major]
    @csv = Twins.get_csv_path
  }
  opt.parse!(ARGV)
end

@quads = Quads::Quads.new(csv: @csv, major: @major)
@quads.print
