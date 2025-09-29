#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../lib/rbcsv'

puts "=== RbCsv 型認識機能テスト ==="
puts

# テストデータ
csv_data = <<~CSV
  name,age,score,rating
  Alice,25,85.5,A
  Bob,30,92,B+
  Charlie,0,100.0,S
CSV

puts "元のCSVデータ:"
puts csv_data
puts

# 通常のparseテスト（すべて文字列）
puts "1. RbCsv.parse (すべて文字列):"
result = RbCsv.parse(csv_data)
result.each_with_index do |row, i|
  puts "Row #{i}: #{row.inspect}"
  if i > 0  # ヘッダー以外
    puts "  age (#{row[1].class}): #{row[1]}"
    puts "  score (#{row[2].class}): #{row[2]}"
  end
end
puts

# 型認識parseテスト
puts "2. RbCsv.parse_typed (数値は数値型):"
result_typed = RbCsv.parse_typed(csv_data)
result_typed.each_with_index do |row, i|
  puts "Row #{i}: #{row.inspect}"
  if i > 0  # ヘッダー以外
    puts "  age (#{row[1].class}): #{row[1]}"
    puts "  score (#{row[2].class}): #{row[2]}"
    puts "  計算可能: age * 2 = #{row[1] * 2}"
  end
end
puts

# エッジケースのテスト
edge_case_csv = <<~CSV
  type,value
  integer,123
  negative,-456
  float,45.6
  scientific,1.23e-4
  empty,
  text,hello world
  mixed,123abc
CSV

puts "3. エッジケーステスト:"
puts "CSVデータ:"
puts edge_case_csv
puts

puts "RbCsv.parse_typed の結果:"
result_edge = RbCsv.parse_typed(edge_case_csv)
result_edge.each_with_index do |row, i|
  if i > 0  # ヘッダー以外
    value = row[1]
    type_name = value.class.name
    puts "#{row[0]}: #{value.inspect} (#{type_name})"
  end
end
puts

# trim版のテスト
csv_with_spaces = "  name  ,  age  ,  score  \n  Alice  ,  25  ,  85.5  "

puts "4. RbCsv.parse_typed! (trim + 型認識):"
puts "CSVデータ（空白付き）: #{csv_with_spaces.inspect}"
result_trim = RbCsv.parse_typed!(csv_with_spaces)
result_trim.each do |row|
  puts "Row: #{row.inspect}"
end
puts

# ファイル書き込み→型認識読み込みテスト
test_file = '/tmp/test_typed.csv'
write_data = [
  ['product', 'price', 'quantity', 'in_stock'],
  ['Apple', '100', '50', 'true'],
  ['Orange', '80.5', '30', 'false'],
  ['Banana', '60.25', '0', 'yes']
]

puts "5. ファイル書き込み→型認識読み込みテスト:"
RbCsv.write(test_file, write_data)
puts "書き込み完了: #{test_file}"

read_typed = RbCsv.read_typed(test_file)
puts "RbCsv.read_typed の結果:"
read_typed.each_with_index do |row, i|
  puts "Row #{i}: #{row.inspect}"
  if i > 0
    puts "  price (#{row[1].class}): #{row[1]}"
    puts "  quantity (#{row[2].class}): #{row[2]}"
  end
end
puts

puts "=== テスト完了 ==="