# R_CSV Project Overview

## Purpose
R_CSV is a Ruby gem that provides CSV processing functionality using Rust extensions for performance. The gem combines Ruby's ease of use with Rust's performance for CSV operations.

## Tech Stack
- **Language**: Ruby (>= 3.2.0) with Rust extensions
- **Build System**: rb_sys for Ruby-Rust integration
- **Testing**: RSpec
- **Linting**: RuboCop
- **Dependencies**: magnus (for Ruby-Rust bindings), rb_sys

## Project Structure
```
r_csv/
├── lib/                    # Ruby source code
│   ├── r_csv.rb           # Main module file
│   └── r_csv/
│       └── version.rb     # Version definition
├── ext/                   # Rust extension code
│   └── r_csv/
│       ├── src/lib.rs     # Rust implementation
│       ├── Cargo.toml     # Rust dependencies
│       └── extconf.rb     # Ruby extension configuration
├── spec/                  # RSpec test files
├── bin/                   # Executable scripts
├── r_csv.gemspec         # Gem specification
├── Rakefile              # Build tasks
└── Gemfile               # Ruby dependencies
```

## Current Status
This appears to be a newly created gem with template code. The Rust extension currently only has a simple "hello" function as a proof of concept.