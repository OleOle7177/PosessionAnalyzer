#!/usr/bin/env ruby
require_relative 'classes/analyzer'

raise 'Wrong number of arguments, expected: 1' if ARGV.size != 1

result = Analyzer.new(ARGV[0]).perform
p result
