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

## Performance

RbCsv leverages Rust for significant performance improvements over pure Ruby CSV libraries, especially for large files.

## Contributing

Found a bug or have a suggestion? Please open an issue on [GitHub](https://github.com/fujitanisora/r_csv/issues).

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Author

**Fujitani Sora**
📧 fujitanisora0414@gmail.com
🐙 [@fujitanisora](https://github.com/fujitanisora)

## License

MIT License. See [LICENSE](https://opensource.org/licenses/MIT) for details.
