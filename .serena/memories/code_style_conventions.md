# Code Style and Conventions

## Ruby Conventions
- **Frozen String Literals**: All Ruby files start with `# frozen_string_literal: true`
- **Module Structure**: Main module is `RCsv` with nested classes/modules
- **Version Management**: Version is defined in `lib/r_csv/version.rb`
- **Error Handling**: Custom error class `RCsv::Error < StandardError`

## File Organization
- **Lib Structure**: Main files in `lib/`, with module-specific files in `lib/r_csv/`
- **Extension Structure**: Rust code in `ext/r_csv/src/`
- **Tests**: RSpec tests in `spec/` directory

## Naming Conventions
- **Gem Name**: `r_csv` (underscore format)
- **Module Name**: `RCsv` (CamelCase)
- **File Names**: Snake_case for Ruby files
- **Constants**: SCREAMING_SNAKE_CASE for version and constants

## Quality Tools
- **RuboCop**: Used for Ruby style enforcement (configured in `.rubocop.yml`)
- **RSpec**: Testing framework with configuration in `.rspec`

## Rust Integration
- **Magnus**: Used for Ruby-Rust bindings
- **RbSys**: Used for building Ruby extensions with Rust
- **Extension Path**: Compiled extensions go to `lib/r_csv/`