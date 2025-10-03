#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'benchmark'
require 'fileutils'
require 'time'
require_relative '../../lib/rbcsv'

# ベンチマーク設定
ITERATIONS = 1000
LARGE_ITERATIONS = 10
CSV_FILE = 'sample.csv'
LARGE_CSV_FILE = 'large_sample.csv'

puts "=" * 60
puts "RbCsv vs Ruby CSV ベンチマーク比較"
puts "=" * 60
puts "Ruby version: #{RUBY_VERSION}"
puts "RbCsv version: #{RbCsv::VERSION}"
puts "Date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
puts

class BenchmarkRunner
  def initialize
    @csv_content = nil
    @large_csv_content = nil
  end

  def setup_sample_data
    # サンプルデータが存在しない場合は作成
    unless File.exist?(CSV_FILE)
      create_sample_csv_file
    end

    @csv_content = File.read(CSV_FILE)
    puts "使用ファイル: #{CSV_FILE}"
    puts "ファイルサイズ: #{@csv_content.bytesize} bytes"

    # レコード数を確認
    records_count = CSV.read(CSV_FILE).length - 1  # ヘッダーを除く
    puts "レコード数: #{records_count}"
    puts
  end

  def create_sample_csv_file
    puts "サンプルCSVファイルを作成中..."
    CSV.open(CSV_FILE, "w") do |csv|
      # ヘッダー
      csv << %w[id name age score department salary active_date]

      # データ行を生成（1000レコード）
      1000.times do |i|
        csv << [
          i + 1,
          "User#{i + 1}",
          rand(20..65),
          rand(60.0..100.0).round(2),
          %w[Engineering Sales Marketing HR][rand(4)],
          rand(40000..120000),
          (Date.today - rand(365)).to_s
        ]
      end
    end
    puts "サンプルファイル作成完了: #{CSV_FILE}"
  end

  def create_large_sample_data
    if File.exist?(LARGE_CSV_FILE)
      puts "既存の大容量ファイルを使用: #{LARGE_CSV_FILE}"
    else
      puts "大容量テストデータを作成中..."
      original_data = CSV.read(CSV_FILE)

      CSV.open(LARGE_CSV_FILE, "w") do |csv|
        # ヘッダー
        csv << original_data.first

        # 元データを50倍に拡張（約50,000レコード）
        50.times do |batch|
          original_data[1..-1].each_with_index do |row, index|
            new_row = row.dup
            new_row[0] = (batch * 1000 + index + 1).to_s  # IDを更新
            csv << new_row
          end
        end
      end

      puts "大容量ファイル作成完了: #{LARGE_CSV_FILE} (#{File.size(LARGE_CSV_FILE)} bytes)"
    end

    # 既存または新規に関わらず、コンテンツを読み込み
    @large_csv_content = File.read(LARGE_CSV_FILE)
    puts "大容量データサイズ: #{@large_csv_content.bytesize} bytes"
    puts
  end

  def run_basic_parsing_benchmark
    puts "🚀 基本パース性能比較 (#{ITERATIONS}回実行)"
    puts "-" * 50

    Benchmark.bm(40) do |x|
      # Ruby標準CSV
      x.report("Ruby CSV.parse") do
        ITERATIONS.times do
          CSV.parse(@csv_content)
        end
      end

      x.report("Ruby CSV.parse (headers: true)") do
        ITERATIONS.times do
          CSV.parse(@csv_content, headers: true)
        end
      end

      # RbCsv 基本機能
      x.report("RbCsv.parse") do
        ITERATIONS.times do
          RbCsv.parse(@csv_content)
        end
      end

      x.report("RbCsv.parse! (with trim)") do
        ITERATIONS.times do
          RbCsv.parse!(@csv_content)
        end
      end

      # RbCsv 型認識機能
      x.report("RbCsv.parse_typed") do
        ITERATIONS.times do
          RbCsv.parse_typed(@csv_content)
        end
      end

      x.report("RbCsv.parse_typed! (typed + trim)") do
        ITERATIONS.times do
          RbCsv.parse_typed!(@csv_content)
        end
      end
    end
    puts
  end

  def run_file_reading_benchmark
    puts "📁 ファイル読み込み性能比較 (#{ITERATIONS}回実行)"
    puts "-" * 50

    Benchmark.bm(40) do |x|
      # Ruby標準CSV
      x.report("Ruby CSV.read") do
        ITERATIONS.times do
          CSV.read(CSV_FILE)
        end
      end

      x.report("Ruby CSV.read (headers: true)") do
        ITERATIONS.times do
          CSV.read(CSV_FILE, headers: true)
        end
      end

      # RbCsv
      x.report("RbCsv.read") do
        ITERATIONS.times do
          RbCsv.read(CSV_FILE)
        end
      end

      x.report("RbCsv.read! (with trim)") do
        ITERATIONS.times do
          RbCsv.read!(CSV_FILE)
        end
      end

      x.report("RbCsv.read_typed") do
        ITERATIONS.times do
          RbCsv.read_typed(CSV_FILE)
        end
      end

      x.report("RbCsv.read_typed! (typed + trim)") do
        ITERATIONS.times do
          RbCsv.read_typed!(CSV_FILE)
        end
      end
    end
    puts
  end

  def run_large_data_benchmark
    create_large_sample_data

    puts "💪 大容量データ性能比較 (#{LARGE_ITERATIONS}回実行)"
    puts "-" * 50

    # 大容量データが正しく読み込まれているかチェック
    if @large_csv_content.nil? || @large_csv_content.empty?
      puts "エラー: 大容量データが読み込まれていません"
      return
    end

    Benchmark.bm(40) do |x|
      # パース性能比較
      x.report("Ruby CSV.parse (large)") do
        LARGE_ITERATIONS.times do
          CSV.parse(@large_csv_content)
        end
      end

      x.report("RbCsv.parse (large)") do
        LARGE_ITERATIONS.times do
          RbCsv.parse(@large_csv_content)
        end
      end

      x.report("RbCsv.parse_typed (large)") do
        LARGE_ITERATIONS.times do
          RbCsv.parse_typed(@large_csv_content)
        end
      end

      # ファイル読み込み性能比較
      x.report("Ruby CSV.read (large file)") do
        LARGE_ITERATIONS.times do
          CSV.read(LARGE_CSV_FILE)
        end
      end

      x.report("RbCsv.read (large file)") do
        LARGE_ITERATIONS.times do
          RbCsv.read(LARGE_CSV_FILE)
        end
      end

      x.report("RbCsv.read_typed (large file)") do
        LARGE_ITERATIONS.times do
          RbCsv.read_typed(LARGE_CSV_FILE)
        end
      end
    end
    puts
  end

  def run_writing_benchmark
    puts "✏️ ファイル書き込み性能比較 (#{ITERATIONS}回実行)"
    puts "-" * 50

    # テスト用の出力ファイル名（絶対パスに修正）
    csv_out = File.join(Dir.pwd, 'benchmark_csv_output.csv')
    rbcsv_out = File.join(Dir.pwd, 'benchmark_rbcsv_output.csv')

    # 書き込み用のテストデータを準備（文字列に変換）
    test_data = []
    100.times do |i|
      test_data << [
        (i + 1).to_s,
        "TestUser#{i + 1}",
        rand(20..65).to_s,
        rand(60.0..100.0).round(2).to_s,
        %w[Engineering Sales Marketing HR][rand(4)],
        rand(40000..120000).to_s,
        (Date.today - rand(365)).to_s
      ]
    end

    Benchmark.bm(40) do |x|
      # Ruby標準CSV書き込み
      x.report("Ruby CSV.open (write)") do
        ITERATIONS.times do
          CSV.open(csv_out, "w") do |csv|
            csv << %w[id name age score department salary active_date]
            test_data.each { |row| csv << row }
          end
        end
      end

      # RbCsv書き込み
      x.report("RbCsv.write") do
        ITERATIONS.times do
          write_data = [%w[id name age score department salary active_date]] + test_data
          RbCsv.write(rbcsv_out, write_data)
        end
      end
    end

    # テストファイルをクリーンアップ
    [csv_out, rbcsv_out].each do |file|
      File.delete(file) if File.exist?(file)
    end
    puts
  end


  def run_type_conversion_comparison
    puts "🔢 型変換処理の比較 (#{ITERATIONS}回実行)"
    puts "-" * 50

    csv_data = CSV.parse(@csv_content)
    rbcsv_data = RbCsv.parse(@csv_content)
    rbcsv_typed_data = RbCsv.parse_typed(@csv_content)

    Benchmark.bm(40) do |x|
      # 手動型変換 vs 自動型変換
      x.report("Manual conversion (CSV)") do
        ITERATIONS.times do
          csv_data[1..-1].map do |row|
            [
              row[0].to_i,      # id to integer
              row[1],           # title (keep as string)
              row[2],           # description (keep as string)
              row[3],           # category (keep as string)
              row[4],           # status (keep as string)
              row[5],           # location (keep as string)
              Time.parse(row[6]), # start_date to time
              Time.parse(row[7]), # end_date to time
              row[8].to_i,      # max_participants to integer
              Time.parse(row[9]), # created_at to time
              Time.parse(row[10]) # updated_at to time
            ]
          end
        end
      end

      x.report("Manual conversion (RbCsv)") do
        ITERATIONS.times do
          rbcsv_data[1..-1].map do |row|
            [
              row[0].to_i,      # id to integer
              row[1],           # title (keep as string)
              row[2],           # description (keep as string)
              row[3],           # category (keep as string)
              row[4],           # status (keep as string)
              row[5],           # location (keep as string)
              Time.parse(row[6]), # start_date to time
              Time.parse(row[7]), # end_date to time
              row[8].to_i,      # max_participants to integer
              Time.parse(row[9]), # created_at to time
              Time.parse(row[10]) # updated_at to time
            ]
          end
        end
      end

      x.report("Automatic conversion (RbCsv typed)") do
        ITERATIONS.times do
          rbcsv_typed_data[1..-1]  # すでに型変換済み
        end
      end
    end
    puts
  end

  def cleanup
    [LARGE_CSV_FILE].each do |file|
      File.delete(file) if File.exist?(file)
    end
  end
  def run_all_benchmarks
    setup_sample_data
    run_basic_parsing_benchmark
    run_file_reading_benchmark
    run_writing_benchmark
    run_large_data_benchmark
    run_type_conversion_comparison
    cleanup
  end
end

# ベンチマーク実行
if __FILE__ == $0
  runner = BenchmarkRunner.new
  runner.run_all_benchmarks
end
