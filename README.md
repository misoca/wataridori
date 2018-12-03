# Wataridori

Wataridori は [esa.io](https://esa.io/) のチーム間のデータマイグレーションツールです。
コピー元のチームの特定のカテゴリ以下の記事をすべて、コピー先のチームにコピーします。

* コピーできる情報
  * 記事タイトル・本文(画像含)・タグ
  * 記事の作成者
  * コメント(投稿者・本文(画像含)のみ)
* コピーできない情報
  * 外部への共有リンクURL
  * リビジョン
  * star, watch
  * 作成/更新日時
  * コメントの作成/更新日時・star, watch

## セットアップ

### 環境変数のセットアップ

```
$ cp .env.sample .env
```

* `ESA_TOKEN`
  * esa の アクセストークンを指定します。
  * アカウントは read / write 権限の両方を持つ必要があります
  * アカウントはコピー先チームのオーナー権限を持つ必要があります
* `ESA_FROM_TEAM`
  * コピー元のチームのチーム名を指定します。
* `ESA_TO_TEAM`
  * コピー先のチームのチーム名を指定します。

## 動作確認の方法

`wataridori` コマンドを実行します。引数はコピーしたいカテゴリのパスです。

```shell
$ bin/wataridori "path/to/category"
```

## テスト方法

RSpec でテストを実行できます。

```
$ bundle exec rspec
```
