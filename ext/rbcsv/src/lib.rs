#[cfg(not(test))]
use magnus::{Error, exception, function, prelude::*, Ruby};

#[cfg(test)]
type Error = Box<dyn std::error::Error>;

fn parse(s: String) -> Result<Vec<Vec<String>>, Error> {
    let mut reader = csv::Reader::from_reader(s.as_bytes());
    let mut records = Vec::new();

    for result in reader.records() {
        match result {
            Ok(record) => {
                let row: Vec<String> = record.iter().map(|field| field.to_string()).collect();
                records.push(row);
            }
            #[cfg(not(test))]
            Err(e) => return Err(Error::new(exception::runtime_error(), format!("CSV parse error: {}", e))),
            #[cfg(test)]
            Err(e) => return Err(Box::new(e)),
        }
    }

    Ok(records)
}

#[cfg(not(test))]
#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("RbCsv")?;
    module.define_singleton_method("parse", function!(parse, 1))?;
    Ok(())
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_parse() {
        let csv_data = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka";
        let result = parse(csv_data.to_string());

        assert!(result.is_ok());

        let records = result.unwrap();
        assert_eq!(records.len(), 2);
        assert_eq!(records[0], vec!["Alice", "25", "Tokyo"]);
        assert_eq!(records[1], vec!["Bob", "30", "Osaka"]);
    }
}
