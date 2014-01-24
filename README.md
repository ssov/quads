# quads

![ss](https://raw.github.com/rkmathi/quads/master/ss.jpg)

## ！！注意！！これ使って留年しちゃっても責任取れないです

* 複数の箇所に属すことができる専門選択科目の単位は、次の優先順位で振ってます

0. 自分の主専攻

0. 上10

0. 他の主専攻


## なんこれ

* TWINS -> 成績 -> 単位修得状況照会 -> ダウンロード -> 「CSV」「Unicode」 -> 出力

> "SIKS20XXXXXXX.csv"を出力
>
> "SIRS20XXXXXXX.csv"じゃないお

* ソフトウェアサイエンス主専攻 => 2

* 情報システム主専攻           => 3

* 知能情報メディア主専攻       => 4

```sh
ruby-2.1.0で動作確認してます。ruby-2.0.0, ruby-1.9.3なら動くかも。

動かし方
  $ ruby quads.rb -c <TWINSのCSVデータ> -m <主専攻のGB?>

例
  $ ruby quads.rb -c SIKS20XXXXXXX.csv -m 3
または
  $ cat ./SIKS20XXXXXXX.csv | ruby quads.rb -m 3
```

## バージョン履歴

[VERSIONS.md](https://github.com/rkmathi/quads/blob/master/VERSIONS.md)

