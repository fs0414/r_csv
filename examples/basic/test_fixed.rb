require_relative '../../lib/rbcsv'

# バージョン確認
# puts RCsv.version_info

# CSVデータの準備
csv_data = <<~CSV
  name,age,city
  Alice,30,New York
  Bob,25,Los Angeles
  Charlie,35,Chicago
CSV

puts "\n=== CSV Parse Test ==="
parsed_data = RCsv.parse(csv_data)
puts "Parsed data:"
parsed_data.each { |row| puts row.inspect }
