#!/usr/bin/env ruby
# frozen_string_literal: true

# RbCsv.write() 機能のテストスクリプト
#
# 実行方法:
#   ruby test_write_functionality.rb
#
# 前提条件:
#   - bundle exec rake compile でライブラリがビルド済みであること

require_relative '../../lib/rbcsv'
require 'fileutils'

class RbCsvWriteTest
  def initialize
    @test_dir = '/tmp/rbcsv_write_tests'
    @success_count = 0
    @total_count = 0
    setup_test_directory
  end

  def run_all_tests
    puts "=" * 60
    puts "RbCsv.write() 機能テスト開始"
    puts "=" * 60
    puts

    test_basic_write
    test_roundtrip_write_read
    test_file_overwrite
    test_empty_data_error
    test_field_count_mismatch_error
    test_single_row_write
    test_unicode_content
    test_special_characters

    puts
    puts "=" * 60
    puts "テスト結果: #{@success_count}/#{@total_count} 成功"
    puts "=" * 60

    cleanup_test_directory

    if @success_count == @total_count
      puts "✅ すべてのテストが成功しました！"
      exit 0
    else
      puts "❌ 一部のテストが失敗しました"
      exit 1
    end
  end

  private

  def setup_test_directory
    FileUtils.mkdir_p(@test_dir)
    puts "テストディレクトリを作成: #{@test_dir}"
  end

  def cleanup_test_directory
    FileUtils.rm_rf(@test_dir)
    puts "テストディレクトリを削除: #{@test_dir}"
  end

  def run_test(name)
    @total_count += 1
    print "#{name}... "

    begin
      yield
      @success_count += 1
      puts "✅ 成功"
    rescue => e
      puts "❌ 失敗: #{e.message}"
      puts "   #{e.backtrace.first}"
    end
  end

  def test_basic_write
    run_test("基本的なCSV書き込み") do
      file_path = File.join(@test_dir, 'basic.csv')
      data = [
        ['name', 'age', 'city'],
        ['Alice', '25', 'Tokyo'],
        ['Bob', '30', 'Osaka']
      ]

      RbCsv.write(file_path, data)

      content = File.read(file_path)
      expected = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka\n"

      raise "書き込み内容が期待値と異なります" unless content == expected
    end
  end

  def test_roundtrip_write_read
    run_test("書き込み→読み込みの往復テスト") do
      file_path = File.join(@test_dir, 'roundtrip.csv')
      original_data = [
        ['product', 'price', 'category'],
        ['Apple', '100', 'Fruit'],
        ['Carrot', '50', 'Vegetable']
      ]

      RbCsv.write(file_path, original_data)
      read_data = RbCsv.read(file_path)

      raise "往復テストで元データと異なります" unless original_data == read_data
    end
  end

  def test_file_overwrite
    run_test("ファイル上書きテスト") do
      file_path = File.join(@test_dir, 'overwrite.csv')

      # 最初のデータ
      first_data = [['old'], ['data']]
      RbCsv.write(file_path, first_data)
      first_content = File.read(file_path)

      # 上書き
      second_data = [['new', 'header'], ['updated', 'content']]
      RbCsv.write(file_path, second_data)
      second_content = File.read(file_path)

      expected_first = "old\ndata\n"
      expected_second = "new,header\nupdated,content\n"

      raise "最初の書き込み内容が不正" unless first_content == expected_first
      raise "上書き後の内容が不正" unless second_content == expected_second
    end
  end

  def test_empty_data_error
    run_test("空データエラーテスト") do
      file_path = File.join(@test_dir, 'empty.csv')

      error_raised = false
      begin
        RbCsv.write(file_path, [])
      rescue RuntimeError => e
        error_raised = true
        raise "エラーメッセージが期待値と異なります" unless e.message.include?("CSV data is empty")
      end

      raise "空データでエラーが発生しませんでした" unless error_raised
    end
  end

  def test_field_count_mismatch_error
    run_test("フィールド数不一致エラーテスト") do
      file_path = File.join(@test_dir, 'mismatch.csv')
      inconsistent_data = [
        ['name', 'age'],
        ['Alice', '25', 'Tokyo']  # 3フィールド（期待は2フィールド）
      ]

      error_raised = false
      begin
        RbCsv.write(file_path, inconsistent_data)
      rescue RuntimeError => e
        error_raised = true
        unless e.message.include?("Field count mismatch") && e.message.include?("line 2")
          raise "エラーメッセージが期待値と異なります: #{e.message}"
        end
      end

      raise "フィールド数不一致でエラーが発生しませんでした" unless error_raised
    end
  end

  def test_single_row_write
    run_test("単一行書き込みテスト") do
      file_path = File.join(@test_dir, 'single.csv')
      data = [['single', 'row', 'test']]

      RbCsv.write(file_path, data)
      content = File.read(file_path)
      expected = "single,row,test\n"

      raise "単一行の書き込み内容が不正" unless content == expected
    end
  end

  def test_unicode_content
    run_test("Unicode文字テスト") do
      file_path = File.join(@test_dir, 'unicode.csv')
      data = [
        ['名前', '年齢', '都市'],
        ['田中太郎', '30', '東京'],
        ['山田花子', '25', '大阪'],
        ['🎉', '😀', '🌸']
      ]

      RbCsv.write(file_path, data)
      read_data = RbCsv.read(file_path)

      raise "Unicode文字の往復テストが失敗" unless data == read_data
    end
  end

  def test_special_characters
    run_test("特殊文字テスト") do
      file_path = File.join(@test_dir, 'special.csv')
      data = [
        ['field1', 'field2', 'field3'],
        ['comma,test', 'quote"test', 'newline\ntest'],
        ['tab\ttest', 'backslash\\test', 'normal']
      ]

      RbCsv.write(file_path, data)
      read_data = RbCsv.read(file_path)

      raise "特殊文字の往復テストが失敗" unless data == read_data
    end
  end
end

# テスト実行
if __FILE__ == $0
  tester = RbCsvWriteTest.new
  tester.run_all_tests
end