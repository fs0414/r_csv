use magnus::{Ruby, Value as MagnusValue, value::ReprValue};

#[derive(Debug, Clone, PartialEq)]
pub enum CsvValue {
    Integer(i64),
    Float(f64),
    String(String),
}

impl CsvValue {
    /// 文字列からCsvValueへの変換
    /// 優先順位: 整数 → 浮動小数点 → 文字列
    pub fn from_str(s: &str) -> Self {
        if s.is_empty() {
            return CsvValue::String(s.to_string());
        }

        if let Ok(i) = s.parse::<i64>() {
            return CsvValue::Integer(i);
        }

        if let Ok(f) = s.parse::<f64>() {
            if f.is_finite() {
                return CsvValue::Float(f);
            }
        }

        CsvValue::String(s.to_string())
    }

    pub fn from_str_trimmed(s: &str) -> Self {
        Self::from_str(s.trim())
    }

    pub fn to_ruby(&self, ruby: &Ruby) -> MagnusValue {
        match self {
            CsvValue::Integer(i) => ruby.integer_from_i64(*i).as_value(),
            CsvValue::Float(f) => ruby.float_from_f64(*f).as_value(),
            CsvValue::String(s) => ruby.str_new(s).as_value(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_from_str_integer() {
        assert_eq!(CsvValue::from_str("123"), CsvValue::Integer(123));
        assert_eq!(CsvValue::from_str("-456"), CsvValue::Integer(-456));
        assert_eq!(CsvValue::from_str("0"), CsvValue::Integer(0));
    }

    #[test]
    fn test_from_str_float() {
        assert_eq!(CsvValue::from_str("123.45"), CsvValue::Float(123.45));
        assert_eq!(CsvValue::from_str("-0.67"), CsvValue::Float(-0.67));
        assert_eq!(CsvValue::from_str("1.23e-4"), CsvValue::Float(0.000123));
        assert_eq!(CsvValue::from_str("3.14159"), CsvValue::Float(3.14159));
    }

    #[test]
    fn test_from_str_string() {
        assert_eq!(CsvValue::from_str("hello"), CsvValue::String("hello".to_string()));
        assert_eq!(CsvValue::from_str(""), CsvValue::String("".to_string()));
        assert_eq!(CsvValue::from_str("123abc"), CsvValue::String("123abc".to_string()));
        assert_eq!(CsvValue::from_str("true"), CsvValue::String("true".to_string()));
    }

    #[test]
    fn test_from_str_edge_cases() {
        // NaN と Infinity は文字列として扱う
        assert_eq!(CsvValue::from_str("NaN"), CsvValue::String("NaN".to_string()));
        assert_eq!(CsvValue::from_str("Infinity"), CsvValue::String("Infinity".to_string()));

        // 非常に大きな数値（i64の範囲を超える）は浮動小数点として扱われる
        assert!(matches!(CsvValue::from_str("99999999999999999999"), CsvValue::Float(_)));
    }

    #[test]
    fn test_from_str_trimmed() {
        assert_eq!(CsvValue::from_str_trimmed("  123  "), CsvValue::Integer(123));
        assert_eq!(CsvValue::from_str_trimmed("  45.6  "), CsvValue::Float(45.6));
        assert_eq!(CsvValue::from_str_trimmed("  hello  "), CsvValue::String("hello".to_string()));
    }
}
