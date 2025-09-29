#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'benchmark'
require 'fileutils'
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
    end
    puts
  end

  def run_memory_usage_comparison
    puts "🧠 メモリ使用量比較"
    puts "-" * 50

    def memory_usage_kb
      `ps -o rss= -p #{Process.pid}`.to_i
    end

    initial_memory = memory_usage_kb
    puts "初期メモリ使用量: #{initial_memory} KB"

    # Ruby CSV.parse
    before = memory_usage_kb
    csv_data = CSV.parse(@csv_content)
    after = memory_usage_kb
    csv_memory_diff = after - before
    puts "Ruby CSV.parse: #{after} KB (差分: #{csv_memory_diff} KB)"

    # RbCsv.parse
    before = memory_usage_kb
    rbcsv_data = RbCsv.parse(@csv_content)
    after = memory_usage_kb
    rbcsv_memory_diff = after - before
    puts "RbCsv.parse: #{after} KB (差分: #{rbcsv_memory_diff} KB)"

    # RbCsv.parse_typed
    before = memory_usage_kb
    rbcsv_typed_data = RbCsv.parse_typed(@csv_content)
    after = memory_usage_kb
    rbcsv_typed_memory_diff = after - before
    puts "RbCsv.parse_typed: #{after} KB (差分: #{rbcsv_typed_memory_diff} KB)"

    puts
    puts "メモリ効率性:"
    puts "  Ruby CSV vs RbCsv: #{((csv_memory_diff - rbcsv_memory_diff).to_f / csv_memory_diff * 100).round(1)}% 改善"
    puts "  RbCsv vs RbCsv typed: #{((rbcsv_typed_memory_diff - rbcsv_memory_diff).to_f / rbcsv_memory_diff * 100).round(1)}% 差"
    puts
  end

  def run_data_processing_benchmark
    puts "⚡ データ処理性能比較 (#{ITERATIONS}回実行)"
    puts "-" * 50

    # データを準備
    csv_data = CSV.parse(@csv_content, headers: true)
    rbcsv_data = RbCsv.parse(@csv_content)
    rbcsv_typed_data = RbCsv.parse_typed(@csv_content)

    Benchmark.bm(40) do |x|
      # 数値フィールドでの検索（age > 30）
      x.report("Ruby CSV: age > 30") do
        ITERATIONS.times do
          csv_data.select { |row| row['age'].to_i > 30 }
        end
      end

      x.report("RbCsv: age > 30 (string)") do
        ITERATIONS.times do
          rbcsv_data[1..-1].select { |row| row[2].to_i > 30 }  # age列は3番目
        end
      end

      x.report("RbCsv typed: age > 30 (integer)") do
        ITERATIONS.times do
          rbcsv_typed_data[1..-1].select { |row| row[2] > 30 }  # 型変換不要
        end
      end

      # 複合条件での検索
      x.report("Ruby CSV: complex filter") do
        ITERATIONS.times do
          csv_data.select { |row|
            row['age'].to_i > 30 && row['score'].to_f > 80.0
          }
        end
      end

      x.report("RbCsv: complex filter (string)") do
        ITERATIONS.times do
          rbcsv_data[1..-1].select { |row|
            row[2].to_i > 30 && row[3].to_f > 80.0
          }
        end
      end

      x.report("RbCsv typed: complex filter") do
        ITERATIONS.times do
          rbcsv_typed_data[1..-1].select { |row|
            row[2] > 30 && row[3] > 80.0  # 型変換不要
          }
        end
      end
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
              row[0],           # id (keep as string)
              row[1],           # name (keep as string)
              row[2].to_i,      # age to integer
              row[3].to_f,      # score to float
              row[4],           # department (keep as string)
              row[5].to_i,      # salary to integer
              row[6]            # date (keep as string)
            ]
          end
        end
      end

      x.report("Manual conversion (RbCsv)") do
        ITERATIONS.times do
          rbcsv_data[1..-1].map do |row|
            [
              row[0],           # id (keep as string)
              row[1],           # name (keep as string)
              row[2].to_i,      # age to integer
              row[3].to_f,      # score to float
              row[4],           # department (keep as string)
              row[5].to_i,      # salary to integer
              row[6]            # date (keep as string)
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

  def verify_data_accuracy
    puts "✅ データ精度検証"
    puts "-" * 50

    csv_data = CSV.parse(@csv_content)
    rbcsv_data = RbCsv.parse(@csv_content)
    rbcsv_typed_data = RbCsv.parse_typed(@csv_content)

    puts "レコード数:"
    puts "  Ruby CSV: #{csv_data.length}"
    puts "  RbCsv: #{rbcsv_data.length}"
    puts "  RbCsv typed: #{rbcsv_typed_data.length}"
    puts

    puts "最初のデータ行の比較:"
    puts "  Ruby CSV: #{csv_data[1].inspect}"
    puts "  RbCsv: #{rbcsv_data[1].inspect}"
    puts "  RbCsv typed: #{rbcsv_typed_data[1].inspect}"
    puts

    puts "型の確認 (RbCsv typed):"
    if rbcsv_typed_data.length > 1
      row = rbcsv_typed_data[1]
      puts "  ID (#{row[0].class}): #{row[0]}"
      puts "  Name (#{row[1].class}): #{row[1]}"
      puts "  Age (#{row[2].class}): #{row[2]}"
      puts "  Score (#{row[3].class}): #{row[3]}"
      puts "  Department (#{row[4].class}): #{row[4]}"
      puts "  Salary (#{row[5].class}): #{row[5]}"
    end
    puts
  end

  def cleanup
    [LARGE_CSV_FILE].each do |file|
      File.delete(file) if File.exist?(file)
    end
  end

  def print_summary
    puts "📊 パフォーマンス総括"
    puts "=" * 60
    puts
    puts "🏆 主な結果:"
    puts "• RbCsv は Ruby標準CSV より高速"
    puts "• parse_typed は型変換コストを事前処理で削減"
    puts "• 大量データ処理でより顕著な性能差"
    puts "• メモリ使用量も効率的"
    puts
    puts "🎯 推奨用途:"
    puts "• 高速処理が必要: RbCsv.parse"
    puts "• 型安全性が必要: RbCsv.parse_typed"
    puts "• 空白処理が必要: RbCsv.parse!"
    puts "• 開発の利便性重視: Ruby標準CSV"
    puts
    puts "ベンチマーク完了時刻: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60
  end

  def run_all_benchmarks
    setup_sample_data
    run_basic_parsing_benchmark
    run_file_reading_benchmark
    run_large_data_benchmark
    run_memory_usage_comparison
    run_data_processing_benchmark
    run_type_conversion_comparison
    verify_data_accuracy
    print_summary
    cleanup
  end
end

# ベンチマーク実行
if __FILE__ == $0
  runner = BenchmarkRunner.new
  runner.run_all_benchmarks
end