## [Unreleased]

## [0.2.0] - 2025-10-04

### Added
- **Type-aware CSV parsing**: New methods for automatic type conversion
  - `parse_typed` and `parse_typed!` for string parsing with type detection
  - `read_typed` and `read_typed!` for file reading with type detection
  - Automatically converts numeric strings to Integer or Float types
  - Preserves strings for non-numeric values
- **Performance benchmarks**: Comprehensive benchmark suite
  - 2.4-3.8x faster than Ruby's standard CSV library for parse operations
  - ~140x faster for type conversion compared to manual Ruby conversion
  - Added benchmark results to README

### Changed
- Improved README with cleaner, more concise documentation
- Added author information and contribution guidelines
- Updated API reference section for better clarity

### Technical
- Added `CsvValue` enum for type-safe value handling
- Implemented efficient type detection algorithm (Integer → Float → String)
- Added comprehensive tests for type conversion functionality

## [0.1.8] - 2025-01-28

### Added
- CSV file writing functionality with `RbCsv.write(file_path, data)` method
- Comprehensive data validation (empty data check, field count consistency)
- Enhanced error handling for write operations (permission errors, invalid data)
- Full test coverage for write functionality with executable test script

### Fixed
- **CRITICAL**: Fixed special character handling in CSV parsing
  - Removed problematic `escape_sanitize` function that interfered with standard CSV escaping
  - Now properly preserves backslashes, newlines, tabs, and other special characters
  - Ensures perfect round-trip fidelity for write/read operations
- Updated RSpec tests to reflect correct CSV parsing behavior

## [0.1.7] - 2025-01-28

### Changed
- **BREAKING**: API redesigned to use function-based approach with `!` suffix for trim functionality
  - `parse(csv)` and `parse!(csv)` for regular and trimmed parsing
  - `read(file)` and `read!(file)` for regular and trimmed file reading
  - Removed option-based API in favor of cleaner function separation
- Major internal refactoring: split code into modular structure
  - `parser.rs`: Core CSV parsing logic
  - `ruby_api.rs`: Ruby bindings and API functions
  - `error.rs`: Error handling and custom error types
- Updated to follow Ruby naming conventions with `!` suffix for modified behavior

### Added
- Comprehensive error handling with detailed error messages
- Support for various CSV edge cases (empty fields, special characters)
- Extensive test coverage for all parsing scenarios
- Improved documentation with DEVELOPMENT.md enhancements

### Fixed
- Memory efficiency improvements in CSV parsing
- Better handling of UTF-8 encoded data
- Consistent error reporting across all functions

### Development
- Added detailed project structure documentation
- Enhanced build and test procedures in DEVELOPMENT.md
- Improved release process documentation

## [0.1.6] - 2025-09-27

### Changed
- Version bump for gem release

## [0.1.5] - 2025-09-27

### Fixed
- Fixed Magnus init function compatibility with version 0.6
- Added missing rb-sys dependency for proper Ruby header linking
- Fixed module name inconsistency in RSpec tests (RCsv → RbCsv)

### Changed
- Updated Magnus initialization to use `#[magnus::init]` attribute
- Improved error handling with Magnus::Error type
- Cleaned up unused imports

### Added
- Documentation for AI-driven gem version upgrade process
- Tests for parse_with_trim functionality

## [0.1.4] - 2025-09-20

- **Fixed**: CSV parse method returning empty array due to incorrect header handling
- **Fixed**: CSV reader now processes all rows instead of skipping header row
- **Improved**: Added proper test coverage for simple CSV parsing

## [0.1.3] - 2025-09-20

- Internal version bump

## [0.1.2] - 2025-09-20

- Internal version bump

## [0.1.1] - 2025-09-20

- Fixed Cargo workspace configuration
- Fixed extconf.rb library name reference
- Minor build fixes

## [0.1.0] - 2025-09-20

- Initial release
