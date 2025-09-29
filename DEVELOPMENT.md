# RbCsv 開発ガイド

このドキュメントでは、rbcsvの開発環境のセットアップ、ビルド方法、テスト手順、リリース手順について詳しく説明します。

## 必要な環境

- **Ruby**: 3.2.0以降（gemspec要件）
- **Rust**: 最新の安定版を推奨（MSRV: 1.75+）
- **Bundler**: gem管理
- **Git**: バージョン管理
- **RubyGems**: 3.3.11以降

### システム要件

- **macOS**: Apple Silicon (arm64) / Intel (x86_64)
- **Linux**: x86_64 / aarch64
- **Windows**: x86_64（実験的サポート）


## 開発環境のセットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/fs0414/rbcsv.git
cd rbcsv
```

### 2. Ruby依存関係のインストール

```bash
bundle install
```

### 3. ネイティブ拡張のビルド

```bash
# 推奨方法（rb_sys使用）
rake compile

# 代替方法（開発時）
bundle exec rake compile
```

### 4. 動作確認

#### CSV パース機能

```bash
# 基本的なパース
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse('a,b\n1,2')"
# 期待される出力: [["a", "b"], ["1", "2"]]

# trim機能付きパース
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse!(' a , b \n 1 , 2 ')"
# 期待される出力: [["a", "b"], ["1", "2"]]
```

#### CSV ファイル読み込み機能

```bash
# CSVファイル読み込み
ruby -I lib -e "require 'rbcsv'; p RbCsv.read('spec/fixtures/test.csv')"
# 期待される出力: [["name", "age", "city"], ["Alice", "25", "Tokyo"], ...]

# trim機能付きファイル読み込み
ruby -I lib -e "require 'rbcsv'; p RbCsv.read!('spec/fixtures/test_with_spaces.csv')"
# 期待される出力: [["name", "age", "city"], ["Alice", "25", "Tokyo"], ...]
```

#### CSV ファイル書き込み機能

```bash
# 基本的なファイル書き込み
ruby -I lib -e "
require 'rbcsv'
data = [['name', 'age', 'city'], ['Alice', '25', 'Tokyo'], ['Bob', '30', 'Osaka']]
RbCsv.write('/tmp/test_output.csv', data)
puts 'File written successfully!'
puts File.read('/tmp/test_output.csv')
"
# 期待される出力:
# File written successfully!
# name,age,city
# Alice,25,Tokyo
# Bob,30,Osaka

#### CSV 型認識機能

```bash
# 基本的な型認識パース
ruby -I lib -e "
require 'rbcsv'
csv_data = 'name,age,score\nAlice,25,85.5\nBob,30,92'
result = RbCsv.parse_typed(csv_data)
p result
puts \"Age type: #{result[1][1].class}\"
puts \"Score type: #{result[1][2].class}\"
"
# 期待される出力:
# [["name", "age", "score"], ["Alice", 25, 85.5], ["Bob", 30, 92]]
# Age type: Integer
# Score type: Float

# trim機能付き型認識パース
ruby -I lib -e "
require 'rbcsv'
csv_data = '  name  ,  age  ,  score  \n  Alice  ,  25  ,  85.5  '
result = RbCsv.parse_typed!(csv_data)
p result
puts \"Age type: #{result[1][1].class}\"
"
# 期待される出力:
# [["name", "age", "score"], ["Alice", 25, 85.5]]
# Age type: Integer

# 型認識ファイル読み込み
ruby -I lib -e "
require 'rbcsv'
result = RbCsv.read_typed('spec/fixtures/test.csv')
p result[1]  # 2行目のデータ
puts \"Age type: #{result[1][1].class}\"
"
# 期待される出力: ["Alice", 25, "Tokyo"] (ageが数値型)

# 型認識の詳細テスト
ruby -I lib -e "
require 'rbcsv'
test_data = 'type,value\ninteger,123\nfloat,45.6\nscientific,1.23e-4\nstring,hello\nempty,'
result = RbCsv.parse_typed(test_data)
result.each_with_index do |row, i|
  next if i == 0  # ヘッダーをスキップ
  value = row[1]
  puts \"#{row[0]}: #{value.inspect} (#{value.class})\"
end
"
# 期待される出力:
# integer: 123 (Integer)
# float: 45.6 (Float)
# scientific: 0.000123 (Float)
# string: "hello" (String)
# empty: "" (String)

# 書き込み→読み込みの往復テスト
ruby -I lib -e "
require 'rbcsv'
data = [['product', 'price'], ['Apple', '100'], ['Orange', '80']]
RbCsv.write('/tmp/roundtrip.csv', data)
result = RbCsv.read('/tmp/roundtrip.csv')
puts 'Original data:'
p data
puts 'Read back data:'
p result
puts 'Match: #{data == result}'
"
# 期待される出力: Match: true

# エラーハンドリングテスト（空データ）
ruby -I lib -e "
require 'rbcsv'
begin
  RbCsv.write('/tmp/empty.csv', [])
rescue => e
  puts 'Error caught: #{e.message}'
end
"
# 期待される出力: Error caught: Invalid Data Error: CSV data is empty

# エラーハンドリングテスト（フィールド数不一致）
ruby -I lib -e "
require 'rbcsv'
begin
  data = [['name', 'age'], ['Alice', '25', 'Tokyo']]
  RbCsv.write('/tmp/mismatch.csv', data)
rescue => e
  puts 'Error caught: #{e.message}'
end
"
# 期待される出力: Error caught: Invalid Data Error: Field count mismatch at line 2: expected 2 fields, got 3 fields

# ファイル上書きテスト
ruby -I lib -e "
require 'rbcsv'
# 最初のデータを書き込み
RbCsv.write('/tmp/overwrite_test.csv', [['old'], ['data']])
puts 'First write:'
puts File.read('/tmp/overwrite_test.csv')

# 新しいデータで上書き
RbCsv.write('/tmp/overwrite_test.csv', [['new', 'data'], ['updated', 'content']])
puts 'After overwrite:'
puts File.read('/tmp/overwrite_test.csv')
"
# 期待される出力: 最初にold,dataが出力され、その後new,data形式に変わる
```

## ビルドプロセス

### 自動ビルド（推奨）

```bash
# 全体ビルド（コンパイル、テスト、リント）
rake

# 拡張のみコンパイル
rake compile

# クリーンビルド
rake clean
rake compile
```

### 手動ビルド手順

```bash
# 1. 前回のビルドをクリーン
rm -rf lib/rbcsv/rbcsv.bundle tmp/ target/

# 2. Rust拡張のコンパイル
cd ext/rbcsv
cargo build --release
cd ../..

# 3. バンドルファイルのコピー（macOSの場合）
cp target/release/librbcsv.dylib lib/rbcsv/rbcsv.bundle

# Linuxの場合
# cp target/release/librbcsv.so lib/rbcsv/rbcsv.bundle
```

### ビルドのトラブルシューティング

#### ABIバージョンの不一致

```bash
# エラー例: "incompatible ABI version"
rm -rf lib/rbcsv/rbcsv.bundle tmp/ target/
bundle exec rake compile
```

#### Rust/Cargoの問題

```bash
# Rust依存関係の更新
cd ext/rbcsv
cargo update
cargo clean
cargo build --release
cd ../..
```

#### Magnus APIエラー

```bash
# 最新のMagnus 0.8.1では、ReprValueトレイトの明示的インポートが必要
# ruby_api.rs で以下が含まれていることを確認:
use magnus::{value::ReprValue};
```

## テスト手順

### Ruby統合テスト

```bash
# 全テスト実行
bundle exec rspec

# 特定のテストファイル
bundle exec rspec spec/rbcsv_spec.rb

# 詳細出力
bundle exec rspec --format documentation
```

### Rustユニットテスト

```bash
# 全Rustテスト
cd ext/rbcsv
cargo test

# 詳細出力
cargo test -- --nocapture

# 特定のテスト
cargo test test_parse_basic
cd ../..
```

### パフォーマンステスト

```bash
# ベンチマーク実行
ruby examples/benchmarks/benchmark.rb

# カスタムテストファイルでのテスト
ruby examples/basic/basic_usage.rb
```

### コードスタイルチェック

```bash
# Rubyコード（RuboCop）
bundle exec rubocop

# Rustコード
cd ext/rbcsv
cargo fmt --check
cargo clippy -- -D warnings
cd ../..
```

## API設計

### 現在のAPI（v0.1.7+）

```ruby
# 関数ベースAPI（`!`サフィックスでtrim機能分離）

# 文字列専用パース（従来型）
RbCsv.parse(csv_string)          # 通常のパース（すべて文字列）
RbCsv.parse!(csv_string)         # trim機能付きパース（すべて文字列）

# 型認識パース（新機能 v0.1.8+）
RbCsv.parse_typed(csv_string)    # 数値を数値型として返す
RbCsv.parse_typed!(csv_string)   # trim + 数値を数値型として返す

# ファイル読み込み
RbCsv.read(file_path)            # 通常のファイル読み込み（すべて文字列）
RbCsv.read!(file_path)           # trim機能付きファイル読み込み（すべて文字列）
RbCsv.read_typed(file_path)      # 型認識ファイル読み込み
RbCsv.read_typed!(file_path)     # trim + 型認識ファイル読み込み

# ファイル書き込み
RbCsv.write(file_path, data)     # CSVファイル書き込み

# データ形式
# 従来型（すべて文字列）
string_data = [
  ["header1", "header2", "header3"],  # ヘッダー行
  ["value1", "value2", "value3"],     # データ行（すべて文字列）
  # ...
]

# 型認識版（数値は数値型）
typed_data = [
  ["name", "age", "score"],           # ヘッダー行（文字列）
  ["Alice", 25, 85.5],               # データ行（文字列, 整数, 浮動小数点）
  ["Bob", 30, 92],                   # データ行（文字列, 整数, 整数）
  # ...
]
```

### API進化の履歴

#### v0.1.6以前（オプションベース）
```ruby
RbCsv.parse(csv_string, {trim: true})
RbCsv.read(file_path, {trim: false})
```

#### v0.1.7+（関数ベース）
```ruby
RbCsv.parse!(csv_string)  # trim版
RbCsv.write(file_path, data)  # 新機能
```

#### v0.1.8+（型認識機能追加）
```ruby
RbCsv.parse_typed(csv_string)    # 数値型自動変換
RbCsv.parse_typed!(csv_string)   # trim + 数値型自動変換
RbCsv.read_typed(file_path)      # ファイル読み込み + 数値型自動変換
RbCsv.read_typed!(file_path)     # trim + ファイル読み込み + 数値型自動変換
```

### 実装アーキテクチャ

1. **parser.rs**: CSV解析・書き込みコア機能、エラーハンドリング
2. **value.rs**: CSV値の型定義（CsvValue enum）と型変換ロジック
3. **ruby_api.rs**: Ruby API関数、Magnus バインディング
4. **lib.rs**: Magnus初期化と関数登録
5. **error.rs**: 包括的なエラーハンドリングとRuby例外変換

#### モジュール詳細

**parser.rs**
- 文字列専用関数: `parse_csv_core`, `parse_csv_file`, `write_csv_file`
- 型認識関数: `parse_csv_typed`, `parse_csv_file_typed`

**value.rs**
- `CsvValue` enum: Integer(i64), Float(f64), String(String)
- 型変換メソッド: `from_str`, `from_str_trimmed`, `to_ruby`
- 優先順位: 整数 → 浮動小数点 → 文字列

**ruby_api.rs**
- 文字列版: `parse`, `parse_trim`, `read`, `read_trim`, `write`
- 型認識版: `parse_typed`, `parse_typed_trim`, `read_typed`, `read_typed_trim`

### 開発時の重要な注意点

#### Ruby拡張ライブラリの特殊性

```bash
# ❌ 避けるべき: cargo buildは直接使用しない
# cargo build は通常のRustライブラリ用で、Ruby拡張では適切にリンクされない

# ✅ 推奨される開発フロー:
cd ext/rbcsv
cargo check           # 構文チェック（リンクなし）
cargo test            # Rust単体テスト
cd ../..
bundle exec rake compile  # Ruby拡張ビルド
bundle exec rspec     # Ruby統合テスト
```

#### ビルドコマンドの使い分け

| コマンド | 用途 | 場所 | 備考 |
|---------|------|------|------|
| `cargo check` | 構文・型チェック | ext/rbcsv | 高速、リンクなし |
| `cargo test` | Rust単体テスト | ext/rbcsv | Rubyシンボル不要 |
| `cargo build` | **使用不可** | - | リンクエラーが発生 |
| `bundle exec rake compile` | Ruby拡張ビルド | プロジェクトルート | 本番用ビルド |
| `bundle exec rspec` | 統合テスト | プロジェクトルート | 完全な機能テスト |

## リリース手順

### 1. 準備フェーズ

```bash
# 開発状況の確認
git status
git log --oneline -10

# 全テストの実行
rake clean
rake

# コードスタイルチェック
bundle exec rubocop
cd ext/rbcsv && cargo clippy && cd ../..
```

### 2. バージョン更新

```bash
# lib/rbcsv/version.rb を編集
vim lib/rbcsv/version.rb
```

```ruby
module RbCsv
  VERSION = "x.y.z"  # セマンティックバージョニング
end
```

### 3. CHANGELOG.md の更新

```markdown
## [x.y.z] - YYYY-MM-DD

### 追加
- 新機能の説明

### 変更
- 既存機能の変更点

### 修正
- バグ修正の説明

### 削除
- 削除された機能（非互換性のある変更）

### セキュリティ
- セキュリティ関連の修正
```

### 4. ビルドとテスト

```bash
# フルクリーンビルド
rake clean
bundle install
rake compile

# 統合テスト
rake spec

# 動作確認
ruby -I lib -e "require 'rbcsv'; puts RbCsv::VERSION"
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse('a,b\n1,2', {})"
```

### 5. Gemビルド

```bash
# Gemファイル生成
gem build rbcsv.gemspec

# 生成確認
ls -la rbcsv-*.gem
```

### 6. 変更のコミット

```bash
git add -A
git commit -m "Release v${VERSION}

主な変更:
- 変更点1の説明
- 変更点2の説明
- バグ修正やパフォーマンス改善"
```

### 7. タグ作成とプッシュ

```bash
VERSION=$(ruby -I lib -e "require 'rbcsv/version'; puts RbCsv::VERSION")
git tag "v${VERSION}"
git push origin main
git push origin "v${VERSION}"
```

### 8. Gem公開（オプション）

```bash
# RubyGems.orgへの公開
gem push rbcsv-${VERSION}.gem

# 公開確認
gem list rbcsv --remote
```

## 開発のベストプラクティス

### コードスタイル

#### Ruby
- 標準的なRuby Style Guideに従う
- RuboCop設定を使用（`.rubocop.yml`）
- frozen_string_literalを有効化

#### Rust
```bash
# フォーマット
cargo fmt

# リント
cargo clippy -- -D warnings

# ドキュメント生成
cargo doc --open
```

### テスト戦略

1. **単体テスト**: 各Rustモジュールに対するcargo test
   - `value.rs`: 型変換ロジックの単体テスト
   - `parser.rs`: CSV解析・型認識機能の単体テスト
2. **統合テスト**: Ruby APIレベルでのRSpecテスト
   - 基本的なCSV処理機能
   - 型認識機能（parse_typed, read_typed系）
   - エラーハンドリング
3. **パフォーマンステスト**: 大きなCSVファイルでのベンチマーク
4. **エッジケーステスト**: 不正なCSV、空ファイル、エンコーディング問題
5. **型認識テスト**: 数値文字列の正確な型変換
   - 整数、浮動小数点、科学記法
   - 混在型のCSVデータ
   - trim機能との組み合わせ

### デバッグ

#### Rust側のデバッグ

```rust
// 開発ビルドでのみ有効
#[cfg(debug_assertions)]
eprintln!("Debug: {:?}", variable);

// ログ出力（log crateを使用）
log::debug!("Debug information: {:?}", data);
```

#### Ruby側のデバッグ

```ruby
# 詳細エラー情報
begin
  RbCsv.parse(invalid_csv, {})
rescue => e
  puts "Error: #{e.class} - #{e.message}"
  puts e.backtrace
end
```

## よくある問題と解決策

### ビルド関連

**問題**: "incompatible ABI version"
```bash
# 解決策: クリーンして同じRubyバージョンで再ビルド
rm -rf lib/rbcsv/rbcsv.bundle tmp/
bundle exec rake compile
```

**問題**: Rustコンパイルエラー
```bash
# 解決策: Rust依存関係の更新
cd ext/rbcsv
cargo update
cargo clean
cargo build --release
cd ../..
```

### 実行時問題

**問題**: 空配列が返される
- **原因**: CSVリーダーの`has_headers`設定
- **解決策**: 最新バージョン（v0.1.4+）を使用

**問題**: 日本語CSV文字化け
- **原因**: エンコーディング問題
- **解決策**: UTF-8での保存を確認、またはエンコーディング変換

### パフォーマンス問題

**問題**: 大きなファイルでメモリ不足
- **解決策**: ストリーミング処理の実装を検討（将来の機能）

**問題**: 予想より遅い処理速度
- **チェック項目**:
  - ファイルI/O vs メモリ処理
  - trimオプションの使用
  - デバッグビルド vs リリースビルド

## コントリビューションガイドライン

### 開発フロー

1. **Issue作成**: バグ報告や機能要求
2. **フォーク**: 個人リポジトリへのフォーク
3. **ブランチ作成**: `feature/new-feature` または `fix/bug-name`
4. **開発**: コードの実装とテスト追加
5. **テスト**: 全テストの実行と確認
6. **プルリクエスト**: 説明と変更内容の詳細

### コミットメッセージ

```
[種類] 簡潔な説明（50文字以内）

詳細な説明（必要に応じて）：
- 変更の理由
- 実装方法
- 影響範囲

関連Issue: #123
```

種類の例:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: コードスタイル
- `refactor`: リファクタリング
- `test`: テスト追加
- `chore`: その他（依存関係更新など）

## ロードマップ

### 短期目標（v0.2.x）
- [ ] カスタム区切り文字サポート
- [ ] ヘッダー行処理
- [ ] エラーハンドリングの改善

### 中期目標（v0.3.x）
- [ ] ストリーミング処理
- [ ] 非同期処理サポート
- [ ] Windows完全サポート

### 長期目標（v1.0.x）
- [ ] 安定したAPI
- [ ] 包括的なドキュメント
- [ ] パフォーマンス最適化完了

## 参考リンク

- [Magnus Documentation](https://docs.rs/magnus/)
- [rb_sys Documentation](https://docs.rs/rb_sys/)
- [Ruby Extension Guide](https://docs.ruby-lang.org/en/master/extension_rdoc.html)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [RubyGems Guides](https://guides.rubygems.org/)
