mod error;
mod parser;
mod ruby_api;
mod value;

use magnus::{Object, Ruby};
use ruby_api::{parse, parse_trim, read, read_trim, write, parse_typed, parse_typed_trim, read_typed, read_typed_trim};

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), magnus::Error> {
    let module = ruby.define_module("RbCsv")?;

    module.define_singleton_method("parse", magnus::function!(parse, 1))?;
    module.define_singleton_method("parse!", magnus::function!(parse_trim, 1))?;
    module.define_singleton_method("read", magnus::function!(read, 1))?;
    module.define_singleton_method("read!", magnus::function!(read_trim, 1))?;
    module.define_singleton_method("write", magnus::function!(write, 2))?;

    // typed variants
    module.define_singleton_method("parse_typed", magnus::function!(parse_typed, 1))?;
    module.define_singleton_method("parse_typed!", magnus::function!(parse_typed_trim, 1))?;
    module.define_singleton_method("read_typed", magnus::function!(read_typed, 1))?;
    module.define_singleton_method("read_typed!", magnus::function!(read_typed_trim, 1))?;

    Ok(())
}

