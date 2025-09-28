use crate::error::{CsvError, ErrorKind};
use std::fs;
use std::path::Path;

/// CSV解析のオプション設定
#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct CsvParseOptions {
    pub trim: bool,
}

impl Default for CsvParseOptions {
    fn default() -> Self {
        Self {
            trim: false,
        }
    }
}

/// エスケープシーケンスを実際の文字に変換
pub fn escape_sanitize(s: &str) -> String {
    s.replace("\\n", "\n")
        .replace("\\r", "\r")
        .replace("\\t", "\t")
        .replace("\\\"", "\"")
        .replace("\\\\", "\\")
}

/// 基本的なCSVパース処理
pub fn parse_csv_core(input: &str, trim_config: csv::Trim) -> Result<Vec<Vec<String>>, CsvError> {
    // 空のデータチェック
    if input.trim().is_empty() {
        return Err(CsvError::empty_data());
    }

    // CSV crate に任せて適切なパースを行う（escape_sanitize は削除）
    let mut reader = csv::ReaderBuilder::new()
        .has_headers(false) // ヘッダーを無効にして、すべての行を読み込む
        .trim(trim_config)
        .from_reader(input.as_bytes());

    let mut records = Vec::new();

    for (line_num, result) in reader.records().enumerate() {
        match result {
            Ok(record) => {
                let row: Vec<String> = record.iter().map(|field| field.to_string()).collect();
                records.push(row);
            }
            Err(e) => {
                // フィールド数不一致エラーを詳細化
                if let csv::ErrorKind::UnequalLengths { expected_len, len, .. } = e.kind() {
                    let error_msg = format!(
                        "Field count mismatch at line {}: expected {} fields, got {} fields",
                        line_num + 1,
                        expected_len,
                        len
                    );
                    return Err(CsvError::new(ErrorKind::FieldCountMismatch, error_msg));
                }

                // その他のcsvエラーを自動変換
                return Err(CsvError::from(e));
            }
        }
    }

    if records.is_empty() {
        return Err(CsvError::empty_data());
    }

    Ok(records)
}

/// オプション設定を使ったCSV解析（文字列用）
pub fn _parse_csv_with_options(input: &str, options: &CsvParseOptions) -> Result<Vec<Vec<String>>, CsvError> {
    let trim_config = if options.trim { csv::Trim::All } else { csv::Trim::None };
    parse_csv_core(input, trim_config)
}

/// オプション設定を使ったCSV解析（ファイル用）
pub fn _parse_csv_file_with_options(file_path: &str, options: &CsvParseOptions) -> Result<Vec<Vec<String>>, CsvError> {
    let trim_config = if options.trim { csv::Trim::All } else { csv::Trim::None };
    parse_csv_file(file_path, trim_config)
}

/// ファイルからCSVを読み込んでパースする
pub fn parse_csv_file(file_path: &str, trim_config: csv::Trim) -> Result<Vec<Vec<String>>, CsvError> {
    // ファイルパスの検証
    let path = Path::new(file_path);
    if !path.exists() {
        return Err(CsvError::io(format!("File not found: {}", file_path)));
    }

    if !path.is_file() {
        return Err(CsvError::io(format!("Path is not a file: {}", file_path)));
    }

    // ファイル読み込み
    let content = match fs::read_to_string(path) {
        Ok(content) => content,
        Err(e) => {
            return Err(CsvError::io(format!("Failed to read file '{}': {}", file_path, e)));
        }
    };

    // CSVパース
    parse_csv_core(&content, trim_config)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_escape_sanitize() {
        let input = "Hello\\nWorld\\t\\\"Test\\\"\\\\End";
        let expected = "Hello\nWorld\t\"Test\"\\End";
        assert_eq!(escape_sanitize(input), expected);
    }

    #[test]
    fn test_parse_csv_core_basic() {
        let csv_data = "a,b,c\n1,2,3";
        let result = parse_csv_core(csv_data, csv::Trim::None);

        assert!(result.is_ok());
        let records = result.unwrap();
        assert_eq!(records.len(), 2);
        assert_eq!(records[0], vec!["a", "b", "c"]);
        assert_eq!(records[1], vec!["1", "2", "3"]);
    }

    #[test]
    fn test_parse_csv_file_not_found() {
        let result = parse_csv_file("non_existent_file.csv", csv::Trim::None);

        assert!(result.is_err());
        if let Err(e) = result {
            assert!(e.to_string().contains("File not found"));
        }
    }

    #[test]
    fn test_parse_csv_file_directory() {
        // ディレクトリを指定した場合のテスト
        let result = parse_csv_file(".", csv::Trim::None);

        assert!(result.is_err());
        if let Err(e) = result {
            assert!(e.to_string().contains("Path is not a file"));
        }
    }

    #[test]
    fn test_parse_csv_file_with_temp_file() {
        use std::io::Write;
        use std::fs::File;

        // 一時ファイルを作成
        let temp_path = "/tmp/test_csv_file.csv";
        let csv_content = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka";

        {
            let mut file = File::create(temp_path).expect("Failed to create temp file");
            file.write_all(csv_content.as_bytes()).expect("Failed to write to temp file");
        }

        // ファイルからCSVを読み込み
        let result = parse_csv_file(temp_path, csv::Trim::None);

        // クリーンアップ
        let _ = std::fs::remove_file(temp_path);

        // 結果を検証
        assert!(result.is_ok());
        let records = result.unwrap();
        assert_eq!(records.len(), 3);
        assert_eq!(records[0], vec!["name", "age", "city"]);
        assert_eq!(records[1], vec!["Alice", "25", "Tokyo"]);
        assert_eq!(records[2], vec!["Bob", "30", "Osaka"]);
    }

    #[test]
    fn test_write_csv_file_basic() {

        let temp_path = "/tmp/test_write_csv.csv";
        let test_data = vec![
            vec!["name".to_string(), "age".to_string(), "city".to_string()],
            vec!["Alice".to_string(), "25".to_string(), "Tokyo".to_string()],
            vec!["Bob".to_string(), "30".to_string(), "Osaka".to_string()],
        ];

        // ファイルに書き込み
        let result = write_csv_file(temp_path, &test_data);
        assert!(result.is_ok(), "Write should succeed");

        // 書き込んだファイルを読み込んで検証
        let content = std::fs::read_to_string(temp_path).expect("Failed to read written file");
        let expected = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka\n";
        assert_eq!(content, expected);

        // クリーンアップ
        let _ = std::fs::remove_file(temp_path);
    }

    #[test]
    fn test_write_csv_file_empty_data() {
        let temp_path = "/tmp/test_write_empty.csv";
        let empty_data: Vec<Vec<String>> = vec![];

        let result = write_csv_file(temp_path, &empty_data);
        assert!(result.is_err());
        if let Err(e) = result {
            assert!(e.to_string().contains("CSV data is empty"));
        }
    }

    #[test]
    fn test_write_csv_file_field_count_mismatch() {
        let temp_path = "/tmp/test_write_mismatch.csv";
        let inconsistent_data = vec![
            vec!["name".to_string(), "age".to_string()],
            vec!["Alice".to_string(), "25".to_string(), "Tokyo".to_string()], // 3 fields instead of 2
        ];

        let result = write_csv_file(temp_path, &inconsistent_data);
        assert!(result.is_err());
        if let Err(e) = result {
            assert!(e.to_string().contains("Field count mismatch"));
        }
    }

    #[test]
    fn test_write_csv_file_permission_denied() {
        // 書き込み権限のないパスをテスト（rootディレクトリ）
        let result = write_csv_file("/root/test.csv", &vec![vec!["test".to_string()]]);
        assert!(result.is_err());
        if let Err(e) = result {
            // Permission deniedまたはParent directory does not existのいずれかになる
            let error_msg = e.to_string();
            assert!(error_msg.contains("Permission denied") || error_msg.contains("Parent directory does not exist"));
        }
    }
}

/// CSVデータをファイルに書き込む
pub fn write_csv_file(file_path: &str, data: &[Vec<String>]) -> Result<(), CsvError> {
    // データ検証：空配列チェック
    if data.is_empty() {
        return Err(CsvError::invalid_data("CSV data is empty"));
    }

    // データ検証：各行のフィールド数一貫性チェック
    if data.len() > 1 {
        let expected_len = data[0].len();
        for (line_num, row) in data.iter().enumerate() {
            if row.len() != expected_len {
                let error_msg = format!(
                    "Field count mismatch at line {}: expected {} fields, got {} fields",
                    line_num + 1,
                    expected_len,
                    row.len()
                );
                return Err(CsvError::invalid_data(error_msg));
            }
        }
    }

    // ファイルパス検証：親ディレクトリの存在確認
    let path = Path::new(file_path);
    if let Some(parent) = path.parent() {
        if !parent.exists() {
            return Err(CsvError::io(format!("Parent directory does not exist: {}", parent.display())));
        }
    }

    // CSV Writer作成とデータ書き込み
    let file = match fs::File::create(path) {
        Ok(file) => file,
        Err(e) => {
            if e.kind() == std::io::ErrorKind::PermissionDenied {
                return Err(CsvError::write_permission(format!("Permission denied: {}", file_path)));
            }
            return Err(CsvError::io(format!("Failed to create file '{}': {}", file_path, e)));
        }
    };

    let mut writer = csv::WriterBuilder::new()
        .has_headers(false)
        .from_writer(file);

    // データ書き込み
    for row in data {
        if let Err(e) = writer.write_record(row) {
            return Err(CsvError::from(e));
        }
    }

    // ファイルフラッシュ：データの確実な書き込み保証
    if let Err(e) = writer.flush() {
        return Err(CsvError::io(format!("Failed to flush data to file '{}': {}", file_path, e)));
    }

    Ok(())
}
