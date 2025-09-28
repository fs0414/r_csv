mod error;
mod parser;
mod ruby_api;

use magnus::{Object, Ruby};
use ruby_api::{parse, parse_trim, read, read_trim};

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), magnus::Error> {
    let module = ruby.define_module("RbCsv")?;

    module.define_singleton_method("parse", magnus::function!(parse, 1))?;
    module.define_singleton_method("parse!", magnus::function!(parse_trim, 1))?;
    module.define_singleton_method("read", magnus::function!(read, 1))?;
    module.define_singleton_method("read!", magnus::function!(read_trim, 1))?;

    Ok(())
}

