# RbCsv Examples

このディレクトリには、RbCsvライブラリの使用方法を示すサンプルコードとテストスクリプトが含まれています。

## ディレクトリ構成

```
examples/
├── basic/              # 基本的な使用例
├── features/           # 特定機能のテスト・デモ
├── benchmarks/         # パフォーマンステストとベンチマーク
└── README.md          # このファイル
```

## 実行方法

全ての例を実行する前に、ライブラリがビルドされていることを確認してください：

```bash
# プロジェクトルートで実行
bundle exec rake compile
```

## 📁 basic/ - 基本的な使用例

### `basic_usage.rb`
RbCsvの基本的な機能（parse, read, write）の使用例です。

```bash
cd examples/basic
ruby basic_usage.rb
```

**機能:**
- CSV文字列のパース
- CSVファイルの読み込み
- CSVファイルの書き込み

### `quick_test.rb`
簡単な動作確認用スクリプトです。

```bash
cd examples/basic
ruby quick_test.rb
```

### `test_fixed.rb`
特定のバグ修正後の動作確認用スクリプトです。

```bash
cd examples/basic
ruby test_fixed.rb
```

### `test_install.rb`
インストール後の動作確認用スクリプトです。

```bash
cd examples/basic
ruby test_install.rb
```

## 🔧 features/ - 特定機能のテスト・デモ

### `test_typed_functionality.rb`
型認識機能（parse_typed, read_typed系）の詳細なテストとデモです。

```bash
cd examples/features
ruby test_typed_functionality.rb
```

**機能:**
- `parse_typed()`: 数値文字列を数値型に自動変換
- `parse_typed!()`: trim + 型変換
- `read_typed()`: ファイル読み込み + 型変換
- `read_typed!()`: ファイル読み込み + trim + 型変換

**型変換例:**
- `"123"` → `123` (Integer)
- `"45.6"` → `45.6` (Float)
- `"1.23e-4"` → `0.000123` (Float)
- `"hello"` → `"hello"` (String)

### `test_write_functionality.rb`
CSV書き込み機能の包括的なテストです。

```bash
cd examples/features
ruby test_write_functionality.rb
```

**機能:**
- 基本的なCSV書き込み
- ファイル上書き動作
- エラーハンドリング（空データ、フィールド数不一致など）
- 書き込み→読み込みの往復テスト

## 📊 benchmarks/ - パフォーマンステスト

### `benchmark.rb`
標準ライブラリのCSVとRbCsvの包括的なパフォーマンス比較です。

```bash
cd examples/benchmarks
ruby benchmark.rb
```

**自動機能:**
- サンプルCSVファイルを自動生成（1000レコード）
- 大容量テストデータを自動作成（50,000レコード）
- ベンチマーク後の自動クリーンアップ

**測定項目:**
- **基本パース性能**: `parse` vs `parse_typed` vs Ruby CSV
- **ファイル読み込み性能**: `read` vs `read_typed` vs Ruby CSV
- **大容量データ処理**: 50,000レコードでの性能比較
- **メモリ使用量**: パース処理でのメモリ効率性
- **データ処理性能**: フィルタリングと検索の速度比較
- **型変換比較**: 手動変換 vs 自動型認識の性能差
- **データ精度検証**: 結果の正確性確認

**期待される結果:**
- RbCsv は Ruby標準CSV より 2-4倍 高速
- `parse_typed` は型変換コストを大幅削減
- メモリ使用量も効率的

### `output_comparison.rb`
標準ライブラリのCSVとRbCsvの出力形式比較です。

```bash
cd examples/benchmarks
ruby output_comparison.rb
```

**要求事項:**
- `sample.csv` ファイルが必要

## 🚀 実行例

### 基本的なCSV処理

```ruby
require_relative '../../lib/rbcsv'

# CSV文字列のパース
csv_data = "name,age,city\nAlice,25,Tokyo\nBob,30,Osaka"
result = RbCsv.parse(csv_data)
# => [["name", "age", "city"], ["Alice", "25", "Tokyo"], ["Bob", "30", "Osaka"]]
```

### 型認識パース

```ruby
require_relative '../../lib/rbcsv'

# 数値を自動的に数値型に変換
csv_data = "name,age,score\nAlice,25,85.5\nBob,30,92"
result = RbCsv.parse_typed(csv_data)
# => [["name", "age", "score"], ["Alice", 25, 85.5], ["Bob", 30, 92]]
#    注意: 25は整数、85.5は浮動小数点数として返される
```

### CSVファイルの書き込みと読み込み

```ruby
require_relative '../../lib/rbcsv'

# データの準備
data = [
  ["product", "price", "quantity"],
  ["Apple", "100", "50"],
  ["Orange", "80.5", "30"]
]

# ファイルに書き込み
RbCsv.write("output.csv", data)

# ファイルから読み込み（型認識付き）
result = RbCsv.read_typed("output.csv")
# => [["product", "price", "quantity"], ["Apple", 100, 50], ["Orange", 80.5, 30]]
#    注意: price と quantity が数値型として読み込まれる
```

## 💡 トラブルシューティング

### よくあるエラー

**1. LoadError: cannot load such file**
```bash
# 解決方法: ライブラリをビルドしてください
bundle exec rake compile
```

**2. RuntimeError: Invalid Data Error**
```bash
# 原因: CSVデータの形式が不正
# 解決方法: データの整合性を確認してください（空データ、フィールド数不一致など）
```

**3. 相対パスエラー**
```bash
# 解決方法: examples/ディレクトリのサブディレクトリから実行してください
cd examples/basic
ruby basic_usage.rb
```

## 📝 新しい例の追加

新しい例を追加する場合：

1. 適切なディレクトリを選択（basic, features, benchmarks）
2. `require_relative '../../lib/rbcsv'` を使用
3. スクリプトの先頭にコメントで目的と使用方法を記述
4. このREADMEを更新

## 🔗 関連ドキュメント

- [メインREADME](../README.md) - 基本的な使用方法
- [開発ガイド](../DEVELOPMENT.md) - 開発者向け詳細情報
- [RSpecテスト](../spec/) - 自動テストスイート