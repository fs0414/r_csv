# Suggested Commands for R_CSV Development

## Development Commands
- `bundle install` - Install dependencies
- `bin/setup` - Setup the development environment
- `bin/console` - Start interactive prompt for experimentation

## Build and Compilation
- `rake compile` - Compile the Rust extension
- `rake build` - Build the gem (includes compilation)
- `bundle exec rake install` - Install gem locally

## Testing and Quality
- `rake spec` - Run RSpec tests
- `rspec` - Alternative way to run tests
- `rake rubocop` - Run RuboCop linting
- `rubocop` - Alternative way to run linting
- `rake` or `rake default` - Run compile, spec, and rubocop together

## Release
- `bundle exec rake release` - Release new version (creates git tag, pushes commits and gem)

## Git Commands (macOS/Darwin)
- `git status` - Check repository status
- `git add .` - Stage all changes
- `git commit -m "message"` - Commit changes
- `git push` - Push to remote repository

## File Operations (macOS/Darwin)
- `ls` - List directory contents
- `cd <directory>` - Change directory
- `grep <pattern> <files>` - Search for patterns
- `find <path> -name <pattern>` - Find files by name