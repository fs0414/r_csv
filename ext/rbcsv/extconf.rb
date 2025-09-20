# frozen_string_literal: true

require "mkmf"
require "rb_sys/mkmf"

create_rust_makefile("rbcsv/rbcsv")

# After Makefile generation, patch it to handle platform-specific output paths
makefile_path = "Makefile"
if File.exist?(makefile_path)
  content = File.read(makefile_path)

  # Find the RUSTLIB target and add copy command to handle platform-specific paths
  content.gsub!(/(\$\(RUSTLIB\): FORCE\n\s+\$\(ECHO\) generating.*\n\s+\$\(CARGO\) rustc.*-l pthread)/,
    '\1' + "\n\t@mkdir -p $(RB_SYS_CARGO_TARGET_DIR)/$(RB_SYS_CARGO_PROFILE_DIR)" +
    "\n\t@if [ -f $(RB_SYS_CARGO_TARGET_DIR)/*/$(RB_SYS_CARGO_PROFILE_DIR)/$(SOEXT_PREFIX)$(TARGET_NAME).$(SOEXT) ]; then cp $(RB_SYS_CARGO_TARGET_DIR)/*/$(RB_SYS_CARGO_PROFILE_DIR)/$(SOEXT_PREFIX)$(TARGET_NAME).$(SOEXT) $(RB_SYS_CARGO_TARGET_DIR)/$(RB_SYS_CARGO_PROFILE_DIR)/$(SOEXT_PREFIX)$(TARGET_NAME).$(SOEXT); fi")

  File.write(makefile_path, content)
end
