#!/usr/bin/env ruby
# frozen_string_literal: true

# Gemが利用可能か確認するためのワンライナーテスト

puts "Testing rbcsv gem installation..."

# gemコマンドでrbcsvが利用可能か確認
system_result = system("ruby -e \"require 'rbcsv'; puts 'rbcsv loaded successfully: version ' + RbCsv::VERSION\"")

if system_result
  puts "\n✅ rbcsv gem is working!"
else
  puts "\n❌ rbcsv gem is not working properly"

  # デバッグ情報
  puts "\nDebugging information:"
  puts "Current Ruby: #{`ruby -v`.strip}"
  puts "Gem list:"
  system("gem list rbcsv")
  puts "\nGem paths:"
  system("ruby -e \"puts $LOAD_PATH.grep(/gem/)\"")
end