use magnus::{Error as MagnusError, Ruby, Value as MagnusValue, value::ReprValue};
use crate::parser::{parse_csv_core, parse_csv_file, write_csv_file, parse_csv_typed, parse_csv_file_typed};

/// CSV文字列をパースする（通常版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `s` - パースするCSV文字列
///
/// # Returns
/// * `Result<Vec<Vec<String>>, MagnusError>` - パース結果またはエラー
pub fn parse(ruby: &Ruby, s: String) -> Result<Vec<Vec<String>>, MagnusError> {
    parse_csv_core(&s, csv::Trim::None)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))
}

/// CSV文字列をパースする（trim版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `s` - パースするCSV文字列
///
/// # Returns
/// * `Result<Vec<Vec<String>>, MagnusError>` - パース結果またはエラー
pub fn parse_trim(ruby: &Ruby, s: String) -> Result<Vec<Vec<String>>, MagnusError> {
    parse_csv_core(&s, csv::Trim::All)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))
}

/// CSVファイルを読み込む（通常版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `file_path` - 読み込むCSVファイルのパス
///
/// # Returns
/// * `Result<Vec<Vec<String>>, MagnusError>` - パース結果またはエラー
pub fn read(ruby: &Ruby, file_path: String) -> Result<Vec<Vec<String>>, MagnusError> {
    parse_csv_file(&file_path, csv::Trim::None)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))
}

/// CSVファイルを読み込む（trim版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `file_path` - 読み込むCSVファイルのパス
///
/// # Returns
/// * `Result<Vec<Vec<String>>, MagnusError>` - パース結果またはエラー
pub fn read_trim(ruby: &Ruby, file_path: String) -> Result<Vec<Vec<String>>, MagnusError> {
    parse_csv_file(&file_path, csv::Trim::All)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))
}

/// CSVファイルに書き込む
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `file_path` - 書き込み先ファイルのパス
/// * `data` - 書き込むCSVデータ（2次元配列）
///
/// # Returns
/// * `Result<(), MagnusError>` - 成功時は空、失敗時はエラー
pub fn write(ruby: &Ruby, file_path: String, data: Vec<Vec<String>>) -> Result<(), MagnusError> {
    write_csv_file(&file_path, &data)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))
}

/// CSV文字列を型認識してパースする（通常版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `s` - パースするCSV文字列
///
/// # Returns
/// * `Result<Vec<Vec<MagnusValue>>, MagnusError>` - パース結果（数値は数値型）またはエラー
pub fn parse_typed(ruby: &Ruby, s: String) -> Result<MagnusValue, MagnusError> {
    let result = parse_csv_typed(&s, csv::Trim::None)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))?;

    // Vec<Vec<CsvValue>> を Ruby配列に変換
    let outer_array = ruby.ary_new();
    for row in result {
        let inner_array = ruby.ary_new();
        for value in row {
            inner_array.push(value.to_ruby(ruby))?;
        }
        outer_array.push(inner_array.as_value())?;
    }

    Ok(outer_array.as_value())
}

/// CSV文字列を型認識してパースする（trim版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `s` - パースするCSV文字列
///
/// # Returns
/// * `Result<Vec<Vec<MagnusValue>>, MagnusError>` - パース結果（数値は数値型）またはエラー
pub fn parse_typed_trim(ruby: &Ruby, s: String) -> Result<MagnusValue, MagnusError> {
    let result = parse_csv_typed(&s, csv::Trim::All)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))?;

    // Vec<Vec<CsvValue>> を Ruby配列に変換
    let outer_array = ruby.ary_new();
    for row in result {
        let inner_array = ruby.ary_new();
        for value in row {
            inner_array.push(value.to_ruby(ruby))?;
        }
        outer_array.push(inner_array.as_value())?;
    }

    Ok(outer_array.as_value())
}

/// CSVファイルを型認識して読み込む（通常版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `file_path` - 読み込むCSVファイルのパス
///
/// # Returns
/// * `Result<Vec<Vec<MagnusValue>>, MagnusError>` - パース結果（数値は数値型）またはエラー
pub fn read_typed(ruby: &Ruby, file_path: String) -> Result<MagnusValue, MagnusError> {
    let result = parse_csv_file_typed(&file_path, csv::Trim::None)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))?;

    // Vec<Vec<CsvValue>> を Ruby配列に変換
    let outer_array = ruby.ary_new();
    for row in result {
        let inner_array = ruby.ary_new();
        for value in row {
            inner_array.push(value.to_ruby(ruby))?;
        }
        outer_array.push(inner_array.as_value())?;
    }

    Ok(outer_array.as_value())
}

/// CSVファイルを型認識して読み込む（trim版）
///
/// # Arguments
/// * `ruby` - Ruby VMの参照
/// * `file_path` - 読み込むCSVファイルのパス
///
/// # Returns
/// * `Result<Vec<Vec<MagnusValue>>, MagnusError>` - パース結果（数値は数値型）またはエラー
pub fn read_typed_trim(ruby: &Ruby, file_path: String) -> Result<MagnusValue, MagnusError> {
    let result = parse_csv_file_typed(&file_path, csv::Trim::All)
        .map_err(|e| MagnusError::new(ruby.exception_runtime_error(), e.to_string()))?;

    // Vec<Vec<CsvValue>> を Ruby配列に変換
    let outer_array = ruby.ary_new();
    for row in result {
        let inner_array = ruby.ary_new();
        for value in row {
            inner_array.push(value.to_ruby(ruby))?;
        }
        outer_array.push(inner_array.as_value())?;
    }

    Ok(outer_array.as_value())
}

#[cfg(test)]
mod tests {

    #[test]
    fn test_parse_basic() {
        let csv_data = "a,b,c\n1,2,3";
        let result = crate::parser::parse_csv_core(csv_data, csv::Trim::None);

        assert!(result.is_ok());
        let records = result.unwrap();
        assert_eq!(records.len(), 2);
        assert_eq!(records[0], vec!["a", "b", "c"]);
        assert_eq!(records[1], vec!["1", "2", "3"]);
    }

    #[test]
    fn test_parse_with_trim_enabled() {
        let csv_data = " a , b , c \n 1 , 2 , 3 ";
        let result = crate::parser::parse_csv_core(csv_data, csv::Trim::All);

        assert!(result.is_ok());
        let records = result.unwrap();
        assert_eq!(records[0], vec!["a", "b", "c"]);
        assert_eq!(records[1], vec!["1", "2", "3"]);
    }

    #[test]
    fn test_parse_with_trim_disabled() {
        let csv_data = " a , b , c \n 1 , 2 , 3 ";
        let result = crate::parser::parse_csv_core(csv_data, csv::Trim::None);

        assert!(result.is_ok());
        let records = result.unwrap();
        assert_eq!(records[0], vec![" a ", " b ", " c "]);
        assert_eq!(records[1], vec![" 1 ", " 2 ", " 3 "]);
    }

    // Note: Ruby API functions that return MagnusError cannot be tested
    // in unit tests because they require a Ruby VM context.
    // File reading functionality is tested in the parser module.
}
