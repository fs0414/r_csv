# Gem Version Upgrade Execution Guide for AI Agent

## Purpose
This document provides step-by-step instructions for AI agents to automatically upgrade and release a new version of the rbcsv gem.

## Prerequisites Check
1. Verify current directory is project root: `/Users/fujitanisora/dev/oss/r_csv`
2. Ensure git repository is clean: `git status` should show no uncommitted changes
3. Confirm on main branch: `git branch --show-current` should return `main`

## Step-by-Step Instructions

### 1. Update Version Number
**File:** `lib/rbcsv/version.rb`
**Action:** Increment version following semantic versioning (MAJOR.MINOR.PATCH)
- PATCH: Bug fixes only (0.1.4 ’ 0.1.5)
- MINOR: New features, backward compatible (0.1.4 ’ 0.2.0)
- MAJOR: Breaking changes (0.1.4 ’ 1.0.0)

### 2. Update CHANGELOG.md
**File:** `CHANGELOG.md`
**Action:** Add new version section at the top with:
```markdown
## [VERSION] - YYYY-MM-DD
### Added
- New features

### Changed
- Modified features

### Fixed
- Bug fixes

### Removed
- Deprecated features
```

### 3. Run Tests
**Commands:**
```bash
# Run Rust tests
cd ext/rbcsv && cargo test && cd ../..

# Run Ruby tests
bundle exec rspec

# Run linter
bundle exec rubocop
```
**Verify:** All tests must pass before proceeding

### 4. Build Rust Extension
**Commands:**
```bash
cd ext/rbcsv
cargo build --release
cd ../..
bundle exec rake compile
```
**Verify:** Build completes without errors

### 5. Build Gem
**Command:** `gem build rbcsv.gemspec`
**Verify:** New .gem file created (e.g., rbcsv-0.1.5.gem)

### 6. Test Local Installation
**Commands:**
```bash
# Install locally
gem install ./rbcsv-*.gem

# Test in IRB
ruby -e "require 'rbcsv'; puts RbCsv::VERSION; puts RbCsv.parse('a,b\n1,2').inspect"
```
**Verify:** Version matches and basic functionality works

### 7. Create Git Commit
**Commands:**
```bash
git add -A
git commit -m "Release version X.Y.Z

- [List key changes here]
"
git tag -a vX.Y.Z -m "Version X.Y.Z"
```

### 8. Push to Repository
**Commands:**
```bash
git push origin main
git push origin --tags
```

### 9. Publish to RubyGems (Optional)
**Command:** `gem push rbcsv-X.Y.Z.gem`
**Note:** Requires RubyGems.org credentials

## Validation Checklist
- [ ] Version updated in version.rb
- [ ] CHANGELOG.md updated with release notes
- [ ] All tests passing (Rust and Ruby)
- [ ] Gem builds successfully
- [ ] Local installation works
- [ ] Git commit and tag created
- [ ] Changes pushed to repository

## Rollback Instructions
If any step fails:
1. `git reset --hard HEAD~1` (if committed)
2. `git tag -d vX.Y.Z` (if tagged)
3. Delete generated .gem file
4. Fix issues and restart process

## Error Handling
- If tests fail: Fix bugs before proceeding
- If build fails: Check Rust/Ruby environment setup
- If gem push fails: Verify RubyGems credentials

## Success Confirmation
After completion, verify:
1. New version tag visible on GitHub
2. Gem file exists in project root
3. Version accessible via: `ruby -e "require 'rbcsv'; puts RbCsv::VERSION"`