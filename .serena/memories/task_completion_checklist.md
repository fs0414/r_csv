# Task Completion Checklist

When completing any development task in r_csv, ensure you run the following commands:

## Required Steps
1. **Compile Extension**: `rake compile` - Ensure Rust extension compiles without errors
2. **Run Tests**: `rake spec` - Ensure all tests pass
3. **Check Code Style**: `rake rubocop` - Ensure code follows style guidelines
4. **Full Check**: `rake` - Runs compile, spec, and rubocop together

## Before Committing
- Ensure all tests pass
- Ensure RuboCop passes without violations
- Ensure Rust extension compiles successfully
- Update version number if needed (in `lib/r_csv/version.rb`)
- Update CHANGELOG.md if applicable

## Release Preparation
- Update version in `lib/r_csv/version.rb`
- Update CHANGELOG.md
- Ensure gemspec is properly configured
- Run full test suite
- Check that `bundle exec rake install` works locally

## Git Workflow
- Use descriptive commit messages
- Keep commits focused and atomic
- Test before committing
- Push to feature branches for review