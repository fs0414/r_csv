# frozen_string_literal: true

RSpec.describe RCsv do
  it "has a version number" do
    expect(RCsv::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end

  describe ".parse" do
    it "parses simple CSV" do
      csv = "a,b,c\n1,2,3"
      result = RCsv.parse(csv)
      expect(result).to eq([["a", "b", "c"], ["1", "2", "3"]])
    end

    it "handles quoted fields" do
      csv = 'name,description\n"John Doe","Software Engineer"'
      result = RCsv.parse(csv)
      expect(result).to eq([["name", "description"], ["John Doe", "Software Engineer"]])
    end
  end

  describe ".generate" do
    it "generates CSV from array" do
      data = [["a", "b"], ["1", "2"]]
      result = RCsv.generate(data)
      expect(result).to eq("a,b\n1,2\n")
    end
  end

  describe ".stream" do
    it "processes CSV in chunks" do
      csv = "a,b\n1,2\n3,4\n5,6"
      result = RCsv.stream(csv, chunk_size: 2)
      expect(result.length).to eq(2)
      expect(result[0]).to eq([["a", "b"], ["1", "2"]])
      expect(result[1]).to eq([["3", "4"], ["5", "6"]])
    end
  end
end
