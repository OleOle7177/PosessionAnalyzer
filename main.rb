#!/usr/bin/env ruby
require_relative 'classes/analyzer'
require_relative 'classes/hash_pretty_print'

raise 'Wrong number of arguments, expected: 1' if ARGV.size != 1

result = Analyzer.new(ARGV[0]).perform

HashPrettyPrint.new.analyzed_hash_print(result)
