# frozen_string_literal: true

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
      csv = 'name,description\n"John Doe","Software Engineer"'
      result = RbCsv.parse(csv)
      expect(result).to eq([["name", "description"], ["John Doe", "Software Engineer"]])
    end

    it "handles escaped characters" do
      csv = "a,b\\n1,2"
      result = RbCsv.parse(csv)
      expect(result).to eq([["a", "b"], ["1", "2"]])
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
end
