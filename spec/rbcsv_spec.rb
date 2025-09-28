# frozen_string_literal: true

require 'fileutils'

RSpec.describe RbCsv do
  it "has a version number" do
    expect(RbCsv::VERSION).not_to be nil
  end

  describe ".parse" do
    it "parses simple CSV" do
      csv = "a,b,c\n1,2,3"
      result = RbCsv.parse(csv)
      expect(result).to eq([["a", "b", "c"], ["1", "2", "3"]])
    end

    it "handles quoted fields" do
      csv = "name,description\n\"John Doe\",\"Software Engineer\""
      result = RbCsv.parse(csv)
      expect(result).to eq([["name", "description"], ["John Doe", "Software Engineer"]])
    end

    it "handles literal backslash characters" do
      csv = "a,b\\\\n1,2"  # literal backslash followed by literal n
      result = RbCsv.parse(csv)
      expect(result).to eq([["a", "b\\\\n1", "2"]])
    end
  end

  describe ".parse!" do
    it "parses CSV with trimming whitespace" do
      csv = " a , b \n 1 , 2 "
      result = RbCsv.parse!(csv)
      expect(result).to eq([["a", "b"], ["1", "2"]])
    end

    it "handles normal CSV without affecting content" do
      csv = "a,b\n1,2"
      result = RbCsv.parse!(csv)
      expect(result).to eq([["a", "b"], ["1", "2"]])
    end
  end

  describe ".read" do
    let(:test_file_path) { File.join(__dir__, "fixtures", "test.csv") }

    it "reads CSV from file" do
      result = RbCsv.read(test_file_path)
      expect(result).to eq([
        ["name", "age", "city"],
        ["Alice", "25", "Tokyo"],
        ["Bob", "30", "Osaka"],
        ["Charlie", "35", "Kyoto"]
      ])
    end

    it "raises error for non-existent file" do
      expect {
        RbCsv.read("non_existent_file.csv")
      }.to raise_error(RuntimeError, /File not found/)
    end

    it "raises error for directory path" do
      expect {
        RbCsv.read(__dir__)
      }.to raise_error(RuntimeError, /Path is not a file/)
    end
  end

  describe ".read!" do
    let(:test_file_path) { File.join(__dir__, "fixtures", "test_with_spaces.csv") }

    it "reads CSV from file with trimming enabled" do
      result = RbCsv.read!(test_file_path)
      expect(result).to eq([
        ["name", "age", "city"],
        ["Alice", "25", "Tokyo"],
        ["Bob", "30", "Osaka"]
      ])
    end

    it "raises error for non-existent file" do
      expect {
        RbCsv.read!("non_existent_file.csv")
      }.to raise_error(RuntimeError, /File not found/)
    end
  end

  describe ".write" do
    let(:temp_file_path) { File.join(__dir__, "tmp", "test_write.csv") }
    let(:test_data) {
      [
        ["name", "age", "city"],
        ["Alice", "25", "Tokyo"],
        ["Bob", "30", "Osaka"]
      ]
    }

    before do
      FileUtils.mkdir_p(File.dirname(temp_file_path))
    end

    after do
      File.delete(temp_file_path) if File.exist?(temp_file_path)
    end

    it "writes CSV data to file" do
      RbCsv.write(temp_file_path, test_data)

      expect(File.exist?(temp_file_path)).to be true
      content = File.read(temp_file_path)
      expect(content).to eq("name,age,city\nAlice,25,Tokyo\nBob,30,Osaka\n")
    end

    it "overwrites existing file" do
      # 最初のデータを書き込み
      RbCsv.write(temp_file_path, [["old", "data"]])

      # 新しいデータで上書き
      RbCsv.write(temp_file_path, test_data)

      content = File.read(temp_file_path)
      expect(content).to eq("name,age,city\nAlice,25,Tokyo\nBob,30,Osaka\n")
    end

    it "raises error for empty data" do
      expect {
        RbCsv.write(temp_file_path, [])
      }.to raise_error(RuntimeError, /CSV data is empty/)
    end

    it "raises error for inconsistent field count" do
      inconsistent_data = [
        ["name", "age"],
        ["Alice", "25", "Tokyo"]  # 3 fields instead of 2
      ]

      expect {
        RbCsv.write(temp_file_path, inconsistent_data)
      }.to raise_error(RuntimeError, /Field count mismatch/)
    end

    it "can write and read back the same data" do
      RbCsv.write(temp_file_path, test_data)
      result = RbCsv.read(temp_file_path)
      expect(result).to eq(test_data)
    end

    it "raises error for permission denied" do
      # 書き込み権限のないパスをテスト
      expect {
        RbCsv.write("/root/test.csv", test_data)
      }.to raise_error(RuntimeError, /(Permission denied|Parent directory does not exist)/)
    end
  end
end
