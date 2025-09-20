# 開発ガイド

このドキュメントでは、rbcsvの開発環境のセットアップ、ビルド方法、リリース手順について説明します。

## 必要な環境

- Ruby 3.0以降
- Rust（最新の安定版を推奨）
- Bundler gem
- Git

## 開発環境のセットアップ

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd r_csv
```

### 2. 依存関係のインストール

```bash
bundle install
```

### 3. ネイティブ拡張のビルド

```bash
rake compile
```

### 4. テストの実行

#### Rubyテスト
```bash
bundle exec rspec
```

#### Rustテスト
```bash
cd ext/rbcsv
cargo test
cd ../..
```

### 5. 動作確認テスト

```bash
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse('a,b\n1,2')"
```

期待される出力: `[["a", "b"], ["1", "2"]]`

## プロジェクト構成

```
r_csv/
├── lib/
│   ├── rbcsv.rb              # メインのRubyモジュール
│   └── rbcsv/
│       ├── version.rb        # バージョン定義
│       └── rbcsv.bundle      # コンパイル済みネイティブ拡張
├── ext/
│   └── rbcsv/
│       ├── src/
│       │   └── lib.rs        # Rust実装
│       ├── Cargo.toml        # Rust依存関係
│       └── extconf.rb        # Ruby拡張の設定
├── spec/                     # Rubyテスト
├── rbcsv.gemspec            # Gem仕様
├── Rakefile                 # ビルドタスク
└── DEVELOPMENT.md           # このファイル
```

## ビルドプロセス

このプロジェクトは、`rb_sys`クレートとRubyの拡張メカニズムを通じてコンパイルされるRustベースのネイティブ拡張を使用しています。

### 手動ビルド手順

1. **前回のビルドをクリーン**（必要に応じて）:
   ```bash
   rm -rf lib/rbcsv/rbcsv.bundle tmp/
   ```

2. **拡張のコンパイル**:
   ```bash
   rake compile
   ```

3. **代替ビルド方法**（rakeが失敗する場合）:
   ```bash
   cd ext/rbcsv
   cargo build --release
   cp ../../target/release/librbcsv.dylib ../../lib/rbcsv/rbcsv.bundle
   cd ../..
   ```

### ビルドのトラブルシューティング

#### ABIバージョンの不一致
「incompatible ABI version」エラーが発生した場合:

1. ビルドと実行で同じRubyバージョンを使用していることを確認
2. クリーンして再ビルド:
   ```bash
   rm -rf lib/rbcsv/rbcsv.bundle tmp/
   rake compile
   ```

#### Rubyバージョンの競合
開発版Ruby（3.5.0devなど）を使用する場合、プリコンパイル済みのgemは動作しません。必ずソースから再ビルドしてください。

## リリース手順

### 1. バージョンの更新

`lib/rbcsv/version.rb`を編集:
```ruby
module RbCsv
  VERSION = "x.y.z"  # バージョン番号を更新
end
```

### 2. CHANGELOG.mdの更新

リリース用の新しいセクションを追加:
```markdown
## [x.y.z] - YYYY-MM-DD

- **修正**: バグ修正の説明
- **追加**: 新機能の説明
- **変更**: 変更点の説明
- **削除**: 削除された機能の説明
```

### 3. ビルドとテスト

```bash
# クリーンビルド
rm -rf lib/rbcsv/rbcsv.bundle tmp/

# 拡張の再ビルド
rake compile

# 機能テスト
ruby -I lib -e "require 'rbcsv'; p RbCsv.parse('a,b\n1,2')"

# テストスイートの実行
bundle exec rspec
```

### 4. Gemのビルド

```bash
gem build rbcsv.gemspec
```

これにより、現在のディレクトリに`rbcsv-x.y.z.gem`が作成されます。

### 5. 変更のコミット

```bash
git add -A
git commit -m "Release vx.y.z

- 主な変更点の簡潔な説明
- 重要な改善や修正のリスト"
```

### 6. Gitタグの作成

```bash
git tag vx.y.z
```

### 7. リポジトリへのプッシュ

```bash
git push origin main
git push origin vx.y.z
```

### 8. Gemの公開（オプション）

RubyGems.orgに公開する場合:

```bash
gem push rbcsv-x.y.z.gem
```

**注意**: RubyGems.orgの適切な認証情報が設定されていることを確認してください。

## 開発のヒント

### コードスタイル

- 標準的なRubyとRustのフォーマット規約に従う
- Rustコードのフォーマットには`cargo fmt`を使用
- 適切なRubyリンティングツールを使用

### テスト

- 新機能のテストを`spec/`に追加
- Rustユニットテストを`ext/rbcsv/src/lib.rs`に追加
- コミット前にすべてのテストが通ることを確認

### デバッグ

Rustコードにデバッグ出力を追加する（開発ビルド用）:

```rust
#[cfg(not(test))]
eprintln!("デバッグ情報: {:?}", variable);
```

これはテスト以外のビルドでのみ出力され、本番環境には影響しません。

## よくある問題

### 拡張が読み込めない

1. 正しいRubyバージョン用に拡張がビルドされているか確認
2. 拡張ファイルの存在を確認: `lib/rbcsv/rbcsv.bundle`
3. 再ビルドを試す: `rake compile`

### 空配列が返される

これはv0.1.4で修正された既知の問題です。CSVリーダーで`has_headers(false)`設定を使用した最新バージョンを使用していることを確認してください。

### ビルドの失敗

1. Rustがインストールされ、最新であることを確認
2. Ruby開発ヘッダーが利用可能であることを確認
3. ビルドキャッシュをクリア: `rm -rf tmp/`

## コントリビューション

1. リポジトリをフォーク
2. 機能ブランチを作成
3. 変更を実施
4. 新機能のテストを追加
5. すべてのテストが通ることを確認
6. プルリクエストを送信

コードは既存のスタイルに従い、適切なテストを含めてください。