#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require_relative '../../lib/rbcsv'

CSV_FILE = 'sample.csv'
csv_content = File.read(CSV_FILE)

puts "=== CSV Output Format Comparison ==="
puts

# Test with a small sample
small_csv = <<~CSV
id,name,age,city
1,Alice,30,Tokyo
2,Bob,25,Osaka
CSV

puts "Small CSV data:"
puts small_csv
puts

puts "=== 1. CSV.parse (default - raw arrays) ==="
csv_parse_raw = CSV.parse(small_csv)
puts "Type: #{csv_parse_raw.class}"
puts "Rows: #{csv_parse_raw.length}"
puts "Data:"
csv_parse_raw.each_with_index { |row, i| puts "  [#{i}] #{row.inspect}" }
puts

puts "=== 2. CSV.parse (headers: true - CSV::Row objects) ==="
csv_parse_headers = CSV.parse(small_csv, headers: true)
puts "Type: #{csv_parse_headers.class}"
puts "Rows: #{csv_parse_headers.length}"
puts "First row type: #{csv_parse_headers.first.class}"
puts "Headers: #{csv_parse_headers.first.headers}"
puts "Data:"
csv_parse_headers.each_with_index { |row, i| puts "  [#{i}] #{row.to_h}" }
puts

puts "=== 3. CSV.table (CSV::Table object) ==="
csv_table = CSV.parse(small_csv, headers: true, header_converters: :symbol)
puts "Type: #{csv_table.class}"
puts "Rows: #{csv_table.length}"
puts "Headers: #{csv_table.first.headers}"
puts "Data:"
csv_table.each_with_index { |row, i| puts "  [#{i}] #{row.to_h}" }
puts

puts "=== 4. RbCsv.parse (current - raw arrays) ==="
rcv_parse = RbCsv.parse(small_csv)
puts "Type: #{rcv_parse.class}"
puts "Rows: #{rcv_parse.length}"
puts "Data:"
rcv_parse.each_with_index { |row, i| puts "  [#{i}] #{row.inspect}" }
puts

puts "=== Output Format Analysis ==="
puts

puts "1. CSV.parse (default):"
puts "   - Returns: Array<Array<String>>"
puts "   - Includes header row as first element"
puts "   - Raw string arrays"
puts "   - Example: [[\"id\", \"name\", \"age\"], [\"1\", \"Alice\", \"30\"]]"
puts

puts "2. CSV.parse (headers: true):"
puts "   - Returns: CSV::Table (Array of CSV::Row)"
puts "   - Header-indexed access: row['name']"
puts "   - Excludes header from data rows"
puts "   - Example: #<CSV::Row id:\"1\" name:\"Alice\" age:\"30\">"
puts

puts "3. RbCsv.parse (current):"
puts "   - Returns: Array<Array<String>>"
puts "   - Includes header row as first element"
puts "   - Raw string arrays"
puts "   - Example: [[\"id\", \"name\", \"age\"], [\"1\", \"Alice\", \"30\"]]"
puts

puts "=== Key Differences ==="
puts

puts "Header handling:"
puts "  CSV.parse (default):     Includes header as row[0]"
puts "  CSV.parse (headers=true): Excludes header, provides row['column'] access"
puts "  RbCsv.parse:              Includes header as row[0] (same as CSV.parse default)"
puts

puts "Data structure:"
puts "  CSV.parse:               Can return CSV::Row objects with named access"
puts "  RbCsv.parse:              Always returns raw Array<String>"
puts

puts "Row count difference:"
csv_default = CSV.parse(small_csv)
csv_headers = CSV.parse(small_csv, headers: true)
rcv_data = RbCsv.parse(small_csv)

puts "  CSV.parse (default):     #{csv_default.length} rows (includes header)"
puts "  CSV.parse (headers=true): #{csv_headers.length} rows (data only)"
puts "  RbCsv.parse:              #{rcv_data.length} rows (includes header)"
puts

puts "=== Compatibility Recommendations ==="
puts

puts "RbCsv already matches CSV.parse (default behavior):"
puts "  - Both include header row as first element"
puts "  - Both return format: [[\"id\", \"name\"], [\"1\", \"Alice\"], [\"2\", \"Bob\"]]"
puts

puts "To add CSV.parse (headers: true) compatibility:"
puts "  - Would need CSV::Row-like objects"
puts "  - Alternative: return {headers: [...], data: [[...], [...]]} structure"
puts

puts "Current RbCsv compatibility:"
puts "  - Matches CSV.parse(content) exactly - both return Array<Array<String>> with headers"
puts "  - Does not yet support CSV.parse(content, headers: true) which returns CSV::Table"
puts

puts "=== Specific Implementation Suggestions ==="
puts

puts "Option 1: Keep current behavior (already compatible):"
puts "  RbCsv.parse(content) → already includes header row ✅"
puts

puts "Option 2: Add options parameter for structured data:"
puts "  RbCsv.parse(content, headers: false) → current behavior (default)"
puts "  RbCsv.parse(content, headers: true) → future: structured data like CSV::Table"
puts

puts "Option 3: Add convenience methods:"
puts "  RbCsv.table(content) → future: structured data with named access"
puts "  RbCsv.foreach(file) → future: streaming with block"
puts
puts "=== Actual Compatibility Status ==="
puts
puts "✅ RbCsv.parse(content) == CSV.parse(content)"
puts "   Both return: Array<Array<String>> with header row included"
puts
puts "❌ RbCsv does not yet support:"
puts "   - CSV.parse(content, headers: true) → CSV::Table with CSV::Row objects"
puts "   - Named column access like row['name']"
puts "   - Header converters (e.g., :symbol)"
puts
puts "Future improvements could add:"
puts "   - RbCsv.parse(content, headers: true) for structured data"
puts "   - RbCsv::Row and RbCsv::Table classes for compatibility"
puts "   - Integration with streaming API for large files"
