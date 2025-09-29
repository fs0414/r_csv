use std::error::Error as StdError;
use std::fmt;

#[derive(Debug)]
pub struct CsvError {
    message: String,
    kind: ErrorKind,
}

#[derive(Debug)]
pub enum ErrorKind {
    // IO関連エラー
    Io,
    // CSV解析エラー
    Parse,
    // UTF-8エンコーディングエラー
    Encoding,
    // フィールド数の不一致
    FieldCountMismatch,
    // 空のCSVデータ
    EmptyData,
    // 書き込み権限エラー
    WritePermission,
    // 無効なデータエラー
    InvalidData,
    // その他のエラー
    #[allow(dead_code)]
    Other,
}

impl fmt::Display for CsvError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self.kind {
            ErrorKind::Io => write!(f, "IO Error: {}", self.message),
            ErrorKind::Parse => write!(f, "Parse Error: {}", self.message),
            ErrorKind::Encoding => write!(f, "Encoding Error: {}", self.message),
            ErrorKind::FieldCountMismatch => write!(f, "Field Count Mismatch: {}", self.message),
            ErrorKind::EmptyData => write!(f, "Empty Data: {}", self.message),
            ErrorKind::WritePermission => write!(f, "Write Permission Error: {}", self.message),
            ErrorKind::InvalidData => write!(f, "Invalid Data Error: {}", self.message),
            ErrorKind::Other => write!(f, "Error: {}", self.message),
        }
    }
}

impl StdError for CsvError {}

impl CsvError {
    pub fn new(kind: ErrorKind, message: impl Into<String>) -> Self {
        CsvError {
            message: message.into(),
            kind,
        }
    }

    pub fn io(message: impl Into<String>) -> Self {
        Self::new(ErrorKind::Io, message)
    }

    pub fn parse(message: impl Into<String>) -> Self {
        Self::new(ErrorKind::Parse, message)
    }

    pub fn encoding(message: impl Into<String>) -> Self {
        Self::new(ErrorKind::Encoding, message)
    }

    #[allow(dead_code)]
    pub fn field_count_mismatch(expected: usize, actual: usize) -> Self {
        Self::new(
            ErrorKind::FieldCountMismatch,
            format!("Expected {} fields, but got {}", expected, actual),
        )
    }

    pub fn empty_data() -> Self {
        Self::new(ErrorKind::EmptyData, "CSV data is empty")
    }

    pub fn write_permission(message: impl Into<String>) -> Self {
        Self::new(ErrorKind::WritePermission, message)
    }

    pub fn invalid_data(message: impl Into<String>) -> Self {
        Self::new(ErrorKind::InvalidData, message)
    }
}

// csv crate error to CsvError conversion
impl From<csv::Error> for CsvError {
    fn from(err: csv::Error) -> Self {
        match err.kind() {
            csv::ErrorKind::Io(_) => CsvError::io(err.to_string()),
            csv::ErrorKind::Utf8 { .. } => CsvError::encoding(err.to_string()),
            csv::ErrorKind::UnequalLengths { .. } => {
                CsvError::new(ErrorKind::FieldCountMismatch, err.to_string())
            }
            _ => CsvError::parse(err.to_string()),
        }
    }
}
