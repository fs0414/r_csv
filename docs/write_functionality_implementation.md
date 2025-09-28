# CSV書き込み機能実装ガイド

## 概要

本ドキュメントは、RbCsv gemにおけるCSV書き込み機能（`RbCsv.write()`）の実装プロセスを詳細に記録したものです。実装から重要なバグ修正、そして最終的なリリースまでの一連の流れを説明しています。

## 実装目標

CSVデータを配列からファイルに書き込む機能を追加し、既存の読み込み機能との完全な互換性を確保する。

```ruby
# 目標API
data = [
  ['name', 'age', 'city'],
  ['Alice', '25', 'Tokyo'],
  ['Bob', '30', 'Osaka']
]
RbCsv.write('output.csv', data)
```

## 実装アーキテクチャ

### 1. コア実装層（Rust）

#### `ext/rbcsv/src/parser.rs`
```rust
pub fn write_csv_file(file_path: &str, data: &[Vec<String>]) -> Result<(), CsvError>
```

**主要機能:**
- データ検証（空配列チェック、フィールド数整合性）
- ファイルパス検証（親ディレクトリ存在確認）
- CSV Writer設定とデータ書き込み
- エラーハンドリング（権限エラー、IOエラー）

#### `ext/rbcsv/src/ruby_api.rs`
```rust
pub fn write(ruby: &Ruby, file_path: String, data: Vec<Vec<String>>) -> Result<(), MagnusError>
```

**役割:**
- RubyとRust間のAPIブリッジ
- データ型変換（Ruby Array → Rust Vec）
- エラー変換（Rust Error → Ruby Exception）

#### `ext/rbcsv/src/error.rs`
```rust
// 新規追加エラータイプ
WritePermission,    // 書き込み権限エラー
InvalidData,        // 無効なデータエラー
```

### 2. Ruby API層

#### `ext/rbcsv/src/lib.rs`
```rust
module.define_singleton_method("write", magnus::function!(write, 2))?;
```

Ruby側からの呼び出しを可能にするAPIメソッド登録。

## データ検証ロジック

### 1. 空データチェック
```rust
if data.is_empty() {
    return Err(CsvError::invalid_data("CSV data is empty"));
}
```

### 2. フィールド数整合性チェック
```rust
let expected_len = data[0].len();
for (line_num, row) in data.iter().enumerate() {
    if row.len() != expected_len {
        let error_msg = format!(
            "Field count mismatch at line {}: expected {} fields, got {} fields",
            line_num + 1, expected_len, row.len()
        );
        return Err(CsvError::invalid_data(error_msg));
    }
}
```

### 3. ファイルパス検証
```rust
let path = Path::new(file_path);
if let Some(parent) = path.parent() {
    if !parent.exists() {
        return Err(CsvError::io(format!("Parent directory does not exist: {}", parent.display())));
    }
}
```

## エラーハンドリング戦略

### 1. 権限エラー
```rust
if e.kind() == std::io::ErrorKind::PermissionDenied {
    return Err(CsvError::write_permission(format!("Permission denied: {}", file_path)));
}
```

### 2. データ検証エラー
- 空データ：`CSV data is empty`
- フィールド数不一致：`Field count mismatch at line X: expected Y fields, got Z fields`

### 3. IOエラー
- ファイル作成失敗：`Failed to create file 'path': error`
- フラッシュ失敗：`Failed to flush data to file 'path': error`

## テスト戦略

### 1. Rust単体テスト（`ext/rbcsv/src/parser.rs`）
```rust
#[test]
fn test_write_csv_file_basic() { /* 基本書き込みテスト */ }

#[test]
fn test_write_csv_file_empty_data() { /* 空データエラーテスト */ }

#[test]
fn test_write_csv_file_field_count_mismatch() { /* フィールド数不一致テスト */ }
```

### 2. RSpec統合テスト（`spec/rbcsv_spec.rb`）
```ruby
describe ".write" do
  it "writes CSV data to file"
  it "overwrites existing file"
  it "raises error for empty data"
  it "raises error for inconsistent field count"
  it "can write and read back the same data"
end
```

### 3. 実行可能テストスクリプト（`test_write_functionality.rb`）
8つの包括的テストケース：
- 基本的なCSV書き込み
- 往復テスト（write → read）
- ファイル上書き
- エラーハンドリング（空データ、フィールド数不一致）
- Unicode文字対応
- 特殊文字処理

## CSV標準準拠

### RFC 4180準拠
- カンマ区切り
- ダブルクォート内のダブルクォートエスケープ（`"""`）
- 改行文字の適切な処理
- フィールド内のカンマ、改行の適切なクォート

### csv crateの活用
```rust
let mut writer = csv::WriterBuilder::new()
    .has_headers(false)
    .from_writer(file);
```

Rustの`csv` crateを使用することで、標準準拠のCSV出力を保証。

## 実装完了基準

1. ✅ **機能実装**: write機能の完全実装
2. ✅ **データ検証**: 包括的な入力データ検証
3. ✅ **エラーハンドリング**: 詳細なエラーメッセージ
4. ✅ **テストカバレッジ**: Rust + Ruby + 実行可能テスト
5. ✅ **ドキュメント**: DEVELOPMENT.mdの更新
6. ✅ **往復互換性**: write/readの完全互換性

## パフォーマンス考慮事項

### 1. メモリ効率
- ストリーミング書き込み（大容量データ対応）
- 不要なデータコピーの回避

### 2. エラー早期検出
- データ検証を書き込み前に実行
- 失敗時のリソース無駄遣い防止

### 3. ファイルハンドリング
- 適切なファイルフラッシュ
- エラー時のファイル状態管理

## 次のステップ

1. **パフォーマンステスト**: 大容量データでのベンチマーク
2. **設定オプション追加**: 区切り文字カスタマイズ等
3. **ストリーミングAPI**: メモリ効率の更なる向上
4. **非同期書き込み**: 大容量データの非同期処理

## 参考資料

- [RFC 4180 - CSV形式仕様](https://tools.ietf.org/html/rfc4180)
- [Rust csv crate documentation](https://docs.rs/csv/)
- [Magnus framework documentation](https://docs.rs/magnus/)