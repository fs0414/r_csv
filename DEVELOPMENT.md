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

## プロジェクト構成

```
r_csv/
├── lib/
│   ├── rbcsv.rb                    # メインのRubyエントリーポイント
│   └── rbcsv/
│       ├── version.rb              # バージョン定義
│       └── rbcsv.bundle            # コンパイル済みネイティブ拡張（生成される）
├── ext/
│   └── rbcsv/
│       ├── src/
│       │   ├── lib.rs              # Rust拡張のエントリーポイント、Magnus初期化
│       │   ├── parser.rs           # CSV解析コア、CsvParseOptions定義
│       │   ├── ruby_api.rs         # Ruby APIバインディング、オプション処理
│       │   └── error.rs            # エラーハンドリング
│       ├── Cargo.toml              # Rust依存関係（Magnus 0.8.1使用）
│       └── extconf.rb              # Ruby拡張ビルド設定
├── spec/
│   ├── rbcsv_spec.rb               # メインのRubyテスト
│   └── spec_helper.rb              # テスト設定
├── docs/                           # ドキュメント
├── target/                         # Rustビルド出力（git無視）
├── tmp/                            # Ruby拡張ビルド中間ファイル（git無視）
├── *.gem                           # ビルド済みgemファイル
├── rbcsv.gemspec                   # Gem仕様
├── Rakefile                        # ビルドタスク（rb_sys使用）
├── Gemfile                         # Ruby依存関係
├── Cargo.toml                      # ワークスペース設定
├── CHANGELOG.md                    # 変更履歴
├── README.md                       # 使用法ガイド
└── DEVELOPMENT.md                  # このファイル
```

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

```bash
# 基本的な動作確認
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse('a,b\n1,2', {})"
# 期待される出力: [["a", "b"], ["1", "2"]]

# オプション付きテスト
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse(' a , b \n 1 , 2 ', {trim: true})"
# 期待される出力: [["a", "b"], ["1", "2"]]
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
ruby benchmark.rb

# カスタムテストファイルでのテスト
ruby test.rb
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

### 現在のAPI（v0.1.6+）

```ruby
# 統一されたオプションベースAPI
RbCsv.parse(csv_string, options = {})
RbCsv.read(file_path, options = {})

# 利用可能なオプション
options = {
  trim: true/false    # 空白文字の除去（デフォルト: false）
  # 将来の拡張:
  # headers: true/false
  # delimiter: ','
}
```

### 実装アーキテクチャ

1. **parser.rs**: CsvParseOptionsと核となるCSV解析機能
2. **ruby_api.rs**: Rubyハッシュオプションの処理とMagnus API
3. **lib.rs**: Magnus初期化と関数登録
4. **error.rs**: エラーハンドリングとRuby例外の変換

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
2. **統合テスト**: Ruby APIレベルでのRSpecテスト
3. **パフォーマンステスト**: 大きなCSVファイルでのベンチマーク
4. **エッジケーステスト**: 不正なCSV、空ファイル、エンコーディング問題

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