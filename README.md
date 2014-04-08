# quads

![ss](https://raw.github.com/rkmathi/quads/master/ss.jpg)

### ！！注意！！これ使って留年しちゃっても知りません☆（ゝω・）v


## なんこれ

単位取得状況から、卒業できるかどうかを判定します。

（現在は情報科学類生のみに対応しています）


## 動かし方

### 1. 動作環境の確認

ruby-2.1で動作確認してます。ruby-2.0, ruby-1.9.3なら動くかも。

```sh
  $ ruby --version
```

### 2. gemのインストール

```sh
  $ bundle install --path .bundle
```

### 3. 実行

```sh
(TWINSにログインまで全て自動で！)
  $ bundle exec ruby quads.rb --login
```

自分でCSVを入力する場合は・・・

TWINS -> 成績 -> 単位修得状況照会 -> ダウンロード -> 「CSV」「Unicode」 -> 出力

> "SIKS20XXXXXXX.csv"を出力
>
> "SIRS20XXXXXXX.csv"じゃないお
>

CSVを自分で入力する場合は、主専攻の番号が必要です。

> ソフトウェアサイエンス主専攻 => 2
>
> 情報システム主専攻           => 3
>
> 知能情報メディア主専攻       => 4
>

```sh
  $ bundle exec ruby quads.rb -c <TWINSのCSVデータ> -m <主専攻のGB?>

(ダウンロードしてきたCSVを使用する場合)
  $ bundle exec ruby quads.rb -c SIKS20XXXXXXX.csv -m 3
(標準入力にCSVを入力する場合)
  $ cat ./SIKS20XXXXXXX.csv | bundle exec ruby quads.rb -m 3
```


## その他

複数の箇所に属すことができる専門選択科目の単位は、次の優先順位で振ってます

0. 自分の主専攻

0. 上10

0. 他の主専攻


## バージョン履歴

[VERSIONS.md](https://github.com/rkmathi/quads/blob/master/VERSIONS.md)

