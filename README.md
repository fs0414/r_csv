# RbCsv

Fast CSV library for Ruby powered by Rust.

## Installation

Add this line to your Gemfile:

```ruby
gem 'rbcsv'
```

Or install directly:

```bash
gem install rbcsv
```

## Usage

```ruby
require 'rbcsv'

# Parse CSV string
csv_data = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka"
result = RbCsv.parse(csv_data)
# => [["name", "age", "city"], ["Alice", "25", "Tokyo"], ["Bob", "30", "Osaka"]]

# Parse with whitespace trimming
result = RbCsv.parse!(" name , age \n Alice , 25 ")
# => [["name", "age"], ["Alice", "25"]]

# Read from file
result = RbCsv.read("data.csv")

# Write to file
data = [["name", "age"], ["Alice", "25"], ["Bob", "30"]]
RbCsv.write("output.csv", data)

# Type-aware parsing (converts numbers automatically)
result = RbCsv.parse_typed("name,age,score\nAlice,25,85.5")
# => [["name", "age", "score"], ["Alice", 25, 85.5]]
```

## API Reference

### Basic Methods
- `RbCsv.parse(string)` - Parse CSV string
- `RbCsv.parse!(string)` - Parse with trimming
- `RbCsv.read(filepath)` - Read CSV file
- `RbCsv.read!(filepath)` - Read with trimming
- `RbCsv.write(filepath, data)` - Write CSV file

### Type-aware Methods
- `RbCsv.parse_typed(string)` - Parse with type conversion
- `RbCsv.parse_typed!(string)` - Parse with trimming and type conversion
- `RbCsv.read_typed(filepath)` - Read with type conversion
- `RbCsv.read_typed!(filepath)` - Read with trimming and type conversion

## Benchmark

Currently, we achieve 2.4 to 3.8 times faster processing for parse operations, with even greater speed improvements for type conversion.
Compared to casting to arbitrary forms using Ruby methods, parse_typed with pre-defined type conversion delivers approximately 140 times faster results.

*exec data 2025/10/04*
```sh
% ruby examples/benchmarks/benchmark.rb

file: bench.csv
file size: 16457 bytes
recode: 100
🚀 parse (1000 times)
--------------------------------------------------
                                               user     system      total        real
Ruby CSV.parse                             0.258438   0.002993   0.261431 (  0.261500)
Ruby CSV.parse (headers: true)             0.329098   0.001348   0.330446 (  0.330398)
RbCsv.parse                                0.085052   0.000358   0.085410 (  0.085403)
RbCsv.parse! (with trim)                   0.112470   0.000246   0.112716 (  0.112703)
RbCsv.parse_typed                          0.096728   0.000512   0.097240 (  0.097227)
RbCsv.parse_typed! (typed + trim)          0.128616   0.000478   0.129094 (  0.129075)

📁 read (1000 times)
--------------------------------------------------
                                               user     system      total        real
Ruby CSV.read                              0.273029   0.030768   0.303797 (  0.398752)
Ruby CSV.read (headers: true)              0.360198   0.027133   0.387331 (  0.478200)
RbCsv.read                                 0.088287   0.021659   0.109946 (  0.169075)
RbCsv.read! (with trim)                    0.119157   0.016301   0.135458 (  0.149894)
RbCsv.read_typed                           0.105971   0.016317   0.122288 (  0.136625)
RbCsv.read_typed! (typed + trim)           0.137821   0.017739   0.155560 (  0.174861)

✏️ write (1000 times)
--------------------------------------------------
                                               user     system      total        real
Ruby CSV.open (write)                      0.409897   0.355344   0.765241 (  1.894642)
RbCsv.write                                0.097875   0.505652   0.603527 (  1.595586)

test data createing
ccreated: large_sample.csv (831947 bytes)
size: 831947 bytes

🔢 parse_typed (1000 times )
--------------------------------------------------
                                               user     system      total        real
Manual conversion (CSV)                    6.093143   0.011365   6.104508 (  6.104026)
Manual conversion (RbCsv)                  6.217609   0.023237   6.240846 (  6.287587)
Automatic conversion (RbCsv typed)         0.000041   0.000001   0.000042 (  0.000041)
```


## Contributing

Found a bug or have a suggestion? Please open an issue on [GitHub](https://github.com/fujitanisora/r_csv/issues).

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Author

**Fujitani Sora**
📧 fujitanisora0414@gmail.com
🐙 [@fujitanisora](https://github.com/fujitanisora)

## License

MIT License. See [LICENSE](https://opensource.org/licenses/MIT) for details.
