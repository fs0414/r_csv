#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'benchmark'
require 'date'
require_relative 'lib/r_csv'

# CSV file path
CSV_FILE = 'sample.csv'

puts "=== CSV Library Benchmark Comparison ==="
puts "File: #{CSV_FILE}"
puts "Ruby version: #{RUBY_VERSION}"
puts

# Read CSV content once for string-based parsing
csv_content = File.read(CSV_FILE)
puts "File size: #{csv_content.bytesize} bytes"
puts "Records: #{CSV.read(CSV_FILE, headers: true).length}"
puts

puts "=== Parse Performance Comparison ==="
Benchmark.bm(35) do |x|

  # Built-in CSV.read - bulk read with headers
  x.report("CSV.read (headers: true)") do
    1000.times do
      data = CSV.read(CSV_FILE, headers: true)
    end
  end

  # Built-in CSV.parse - from string with headers
  x.report("CSV.parse (headers: true)") do
    1000.times do
      data = CSV.parse(csv_content, headers: true)
    end
  end

  # Built-in CSV.parse - raw parsing
  x.report("CSV.parse (raw)") do
    1000.times do
      data = CSV.parse(csv_content)
    end
  end

  # r_csv - Rust extension parsing
  x.report("RCsv.parse (Rust)") do
    1000.times do
      data = RCsv.parse(csv_content)
    end
  end

end

puts "\n=== Memory Usage Comparison ==="

# Helper to measure memory usage
def memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end

puts "Initial memory usage: #{memory_usage} KB"

# CSV.read
before_read = memory_usage
data_read = CSV.read(CSV_FILE, headers: true)
after_read = memory_usage
puts "After CSV.read: #{after_read} KB (diff: #{after_read - before_read} KB)"

# CSV.parse
before_parse = memory_usage
data_parse = CSV.parse(csv_content)
after_parse = memory_usage
puts "After CSV.parse: #{after_parse} KB (diff: #{after_parse - before_parse} KB)"

# r_csv
before_rcv = memory_usage
data_rcv = RCsv.parse(csv_content)
after_rcv = memory_usage
puts "After RCsv.parse: #{after_rcv} KB (diff: #{after_rcv - before_parse} KB)"

puts "\n=== Data Accuracy Verification ==="
puts "CSV.read rows: #{data_read.length}"
puts "CSV.parse rows: #{data_parse.length}"
puts "RCsv.parse rows: #{data_rcv.length}"

# Verify first row data
if data_rcv.length > 0
  puts "\nFirst row comparison:"
  puts "CSV.read: #{data_read.first.fields}"
  puts "CSV.parse: #{data_parse[1]}"  # Skip header
  puts "RCsv.parse: #{data_rcv[0]}"
end

puts "\n=== Large Data Simulation ==="
puts "Generating 10,000 records for benchmark..."

# Generate large data
large_csv_file = 'large_sample.csv'
CSV.open(large_csv_file, "w") do |csv|
  # Write header
  csv << data_read.first.headers

  # Duplicate original data 100 times
  100.times do |batch|
    data_read.each_with_index do |row, index|
      new_row = row.fields.dup
      new_row[0] = (batch * 100 + index + 1).to_s  # Update ID
      csv << new_row
    end
  end
end

large_csv_content = File.read(large_csv_file)
puts "Large data file created: #{File.size(large_csv_file)} bytes"

# Large data benchmark
puts "\n=== Large Data Performance Test ==="
Benchmark.bm(35) do |x|

  x.report("CSV.read (large, 10 times)") do
    10.times do
      large_data = CSV.read(large_csv_file, headers: true)
    end
  end

  x.report("CSV.parse (large, 10 times)") do
    10.times do
      large_data = CSV.parse(large_csv_content, headers: true)
    end
  end

  x.report("RCsv.parse (large, 10 times)") do
    10.times do
      large_data = RCsv.parse(large_csv_content)
    end
  end

end

puts "\n=== Processing Speed Comparison ==="
csv_data = CSV.parse(csv_content, headers: true)
rcv_data = RCsv.parse(csv_content)

Benchmark.bm(35) do |x|

  # Search by category with CSV data
  x.report("CSV search 'tech' (1000x)") do
    1000.times do
      csv_data.select { |row| row['category'] == 'tech' }
    end
  end

  # Search by category with r_csv data (need to implement indexing)
  x.report("RCsv search 'tech' (1000x)") do
    1000.times do
      rcv_data.select { |row| row[3] == 'tech' }  # category is 4th column (index 3)
    end
  end

  # Complex filtering with CSV
  x.report("CSV complex filter (1000x)") do
    1000.times do
      csv_data.select { |row|
        row['category'] == 'tech' && row['status'] == 'published'
      }
    end
  end

  # Complex filtering with r_csv
  x.report("RCsv complex filter (1000x)") do
    1000.times do
      rcv_data.select { |row|
        row[3] == 'tech' && row[4] == 'published'
      }
    end
  end

end

# Cleanup
File.delete(large_csv_file)

puts "\n=== Performance Summary ==="
puts "r_csv provides raw array data (faster for pure parsing)"
puts "CSV provides structured data with headers (better for development)"
puts "Choose based on your use case: speed vs convenience"
puts "\n=== Benchmark Complete ==="
puts "Execution time: #{Time.now}"