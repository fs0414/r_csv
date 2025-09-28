# RbCsv

A fast CSV processing library for Ruby, built with Rust for high performance. RbCsv provides simple, efficient methods for parsing CSV strings, reading CSV files, and writing CSV data to files.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

### Parsing CSV strings

```ruby
require 'rbcsv'

# Parse CSV string
csv_data = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka"
result = RbCsv.parse(csv_data)
# => [["name", "age", "city"], ["Alice", "25", "Tokyo"], ["Bob", "30", "Osaka"]]

# Parse CSV with automatic whitespace trimming
csv_with_spaces = " name , age , city \n Alice , 25 , Tokyo "
result = RbCsv.parse!(csv_with_spaces)
# => [["name", "age", "city"], ["Alice", "25", "Tokyo"]]
```

### Reading CSV files

```ruby
# Read CSV file
result = RbCsv.read("data.csv")
# => [["name", "age", "city"], ["Alice", "25", "Tokyo"], ["Bob", "30", "Osaka"]]

# Read CSV file with automatic whitespace trimming
result = RbCsv.read!("data_with_spaces.csv")
# => [["name", "age", "city"], ["Alice", "25", "Tokyo"], ["Bob", "30", "Osaka"]]
```

### Writing CSV files

```ruby
# Prepare data
data = [
  ["name", "age", "city"],
  ["Alice", "25", "Tokyo"],
  ["Bob", "30", "Osaka"]
]

# Write CSV data to file
RbCsv.write("output.csv", data)
# Creates a file with:
# name,age,city
# Alice,25,Tokyo
# Bob,30,Osaka
```

### Error Handling

RbCsv provides detailed error messages for various scenarios:

```ruby
# Empty data
RbCsv.write("output.csv", [])
# => RuntimeError: Invalid Data Error: CSV data is empty

# Inconsistent field count
data = [["name", "age"], ["Alice", "25", "Tokyo"]]  # 3 fields in second row
RbCsv.write("output.csv", data)
# => RuntimeError: Invalid Data Error: Field count mismatch at line 2: expected 2 fields, got 3 fields

# File not found
RbCsv.read("nonexistent.csv")
# => RuntimeError: IO Error: File not found: nonexistent.csv
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/r_csv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/r_csv/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RCsv project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/r_csv/blob/master/CODE_OF_CONDUCT.md).
