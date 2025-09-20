#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rbcsv'

puts "rbcsv gem version: #{RbCsv::VERSION}"
puts "Testing CSV parsing..."

# Simple CSV data for testing
csv_data = <<~CSV
  name,age,city
  Alice,30,Tokyo
  Bob,25,Osaka
  Carol,35,Kyoto
CSV

begin
  result = RbCsv.parse(csv_data)

  puts "\nParsing successful!"
  puts "Number of records: #{result.length}"
  puts "\nParsed data:"
  result.each_with_index do |row, index|
    puts "Row #{index}: #{row.inspect}"
  end

  puts "\nVerifying structure:"
  puts "First row: #{result[0]}"
  puts "Second row: #{result[1]}"
  puts "Name from first record: #{result[0][0]}"
  puts "Age from first record: #{result[0][1]}"

  puts "\n✅ rbcsv gem is working correctly!"
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace
  exit 1
end