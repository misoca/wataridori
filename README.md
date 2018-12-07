# Wataridori

Wataridori は [esa.io](https://esa.io/) のチーム間のデータマイグレーションツールです。
コピー元のチームの特定のカテゴリ以下の記事をすべて、コピー先のチームにコピーします。

* コピーできる情報
  * 記事タイトル・本文・タグ
  * 記事の作成者
  * コメント(投稿者・本文のみ)
* コピーできない情報
  * 外部への共有リンクURL
  * リビジョン
  * star, watch
  * 作成/更新日時
  * コメントの作成/更新日時・star, watch
  * 添付ファイル
    * 添付ファイルの URL が外部から参照可能であれば、コピー先チームでも添付ファイルはそのまま利用できます

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

## 実行方法

`wataridori` コマンドを実行します。引数無しで実行すると USAGE が表示されます。

```shell
$ bin/wataridori
Usage: bin/wataridori [mode]
  bulk_copy "path/to/category" [path/to/copy_result.yml]
  replace_links path/to/copy_result.yml [..path/to/copy_result2.yml]
  copy_and_replace "path/to/category" [path/to/copy_result.yml]
```

### 記事の一括コピー(bulk_copy)

```shell
$ bin/wataridori bulk_copy "path/to/category" [path/to/copy_result.yml]
```

指定したカテゴリの記事を、コピー元からコピー先へ一括でコピーします。
URL の置き換えは行いません。

第一引数がコピーするカテゴリです。

第二引数にはコピーした結果を保存しておく YAML のパスを指定します。
省略するとコピー結果は保存しません。

### URL の置き換え(replade_links)

```shell
$ bin/wataridori replace_links path/to/copy_result.yml [..path/to/copy_result2.yml]
```

bulk_copy の結果を使って、URL の置き換えを行います。
コピー元にしかない記事へのリンクはコピー元の記事へリンクを張ります。
コピー先にできた記事は、コピー先にリンクを張ります。
現在は、コピー先のチームの記事のリンクの置き換えにのみ対応しています。

引数には bulk_copy で生成された YAML のパスを指定します。
複数指定することも可能です。

### 一括コピーと URL 置き換え(copy_and_replace)

```shell
$ bin/wataridori replace_links "path/to/category" [path/to/copy_result.yml]
```

bulk_copy と copy_and_replace を一度に行います。

第一引数がコピーするカテゴリです。

第二引数にはコピーした結果を保存しておく YAML のパスを指定します。
省略するとコピー結果は保存しません。


## テスト方法

RSpec でテストを実行できます。

```
$ bundle exec rspec
```
