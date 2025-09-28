## [Unreleased]

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
