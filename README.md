
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jpstat <a href="https://uchidamizuki.github.io/jpstat/"><img src="man/figures/logo.png" align="right" height="139"/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/jpstat)](https://CRAN.R-project.org/package=jpstat)

<!-- badges: end -->

**README is currently only available in Japanese.**

jpstatは日本政府統計のポータルサイトであるe-Statを中心に，
政府統計APIを利用するためのツールを提供します．

このパッケージは **e-Stat API への対応を中核** とし，
e-Stat の機能拡充に注力します．
不動産情報ライブラリ API への対応は **補助的な機能 (experimental)** です．
外部APIは終了・仕様変更のリスクがあるため，
今後さらに対応APIを増やす予定はありません．

現在，以下のAPIに対応しています．

- e-Stat API（中核）: <https://www.e-stat.go.jp/api/>
- 不動産情報ライブラリ API（補助・experimental）:
  <https://www.reinfolib.mlit.go.jp/>

なお，RESAS API（地域経済分析システム）は2025年3月24日に提供を終了したため，
`resas()` は廃止 (defunct) されました．
都道府県・市区町村単位のデータについては，国土交通省データプラットフォーム
(DPF) の GraphQL API (<https://www.mlit-data.jp/>) などの利用を検討してください．

**「このサービスは、政府統計総合窓口(e-Stat)のAPI機能を使用していますが、サービスの内容は国によって保証されたものではありません。」**

## インストール方法

``` r
install.packages("jpstat")
```

jpstatの開発版は，[GitHub](https://github.com/)から以下の方法でインストールできます．

``` r
# install.packages("devtools")
devtools::install_github("UchidaMizuki/jpstat")
```

``` r
library(jpstat)
library(dplyr)
```

## e-Stat API

e-Stat APIの利用にはアカウント登録 (appIdと呼ばれるAPIキーの発行)
が必要です
(詳しくは[ホームページ](https://www.e-stat.go.jp/api/)を参照してください)．
また，データ利用に際しては[利用規約](https://www.e-stat.go.jp/terms-of-use)に従う必要があります．

データ取得・整形の一連の流れは以下のようになります．
ここでは，[国勢調査データ](https://www.e-stat.go.jp/dbview?sid=0003413949)を対象として，
2010・2015年の東京都・大阪府における男女別人口を取得します．
詳細な使用方法は[こちら](https://github.com/uchidamizuki/jpstat/blob/main/README-estat.md)を参照してください．

    # APIキーの設定
    Sys.setenv(ESTAT_API_KEY = "Your appId")

    # メタ情報の取得
    census <- estat(statsDataId = "https://www.e-stat.go.jp/dbview?sid=0003410379")
    census

    #> # ☐ tab:   表章項目         [2] <code, name, level, unit>
    #> # ☐ cat01: 男女_時系列      [3] <code, name, level>
    #> # ☐ area:  地域_時系列      [50] <code, name, level, parentCode>
    #> # ☐ time:  時間軸（調査年） [21] <code, name, level>
    #> # 
    #> # Please `activate()`.

``` r
# 2010・2015年の東京都・大阪府における男女別人口を取得
census <- census |> 
  
  activate(tab) |> 
  filter(name == "人口") |> 
  select() |> 
  
  activate(cat01) |> 
  rekey("sex") |> 
  filter(name %in% c("男", "女")) |> 
  select(name) |> 
  
  activate(area) |> 
  rekey("pref") |> 
  filter(name %in% c("東京都", "大阪府")) |> 
  select(code, name) |> 
  
  activate(time) |> 
  rekey("year") |> 
  filter(name %in% c("2010年", "2015年")) |> 
  select(name) |> 
  
  collect(n = "pop")
#> The total number of data is 8.

knitr::kable(census)
```

| sex_name | pref_code | pref_name | year_name | pop     |
|:---------|:----------|:----------|:----------|:--------|
| 男       | 13000     | 東京都    | 2010年    | 6512110 |
| 男       | 13000     | 東京都    | 2015年    | 6666690 |
| 男       | 27000     | 大阪府    | 2010年    | 4285566 |
| 男       | 27000     | 大阪府    | 2015年    | 4256049 |
| 女       | 13000     | 東京都    | 2010年    | 6647278 |
| 女       | 13000     | 東京都    | 2015年    | 6848581 |
| 女       | 27000     | 大阪府    | 2010年    | 4579679 |
| 女       | 27000     | 大阪府    | 2015年    | 4583420 |

## RESAS API（提供終了）

RESAS API は2025年3月24日に提供を終了しました．これに伴い `resas()`
は廃止 (defunct) され，呼び出すとエラーになります．代替については上記を参照してください．

## 不動産情報ライブラリ API

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

不動産取引価格情報は，従来の「土地総合情報システム」APIから
[不動産情報ライブラリ](https://www.reinfolib.mlit.go.jp/) のAPIへ移行しました．
利用にはアカウント登録 (APIキーの発行) が必要です
([API利用申請](https://www.reinfolib.mlit.go.jp/api/request/)，
[API操作説明](https://www.reinfolib.mlit.go.jp/help/apiManual/))．

`webland_trade()` では `year`（取引年）と `quarter`（四半期）が必須で，
`pref_code`（都道府県コード），`city_code`（市区町村コード），
`station_code`（駅コード）のいずれか1つ以上を指定します．

``` r
Sys.setenv(REINFOLIB_API_KEY = "Your API key")

trade <- webland_trade() |>
  itemise(year = "2015",
          quarter = "1",
          pref_code = "01",
          city_code = "01101") |>
  collect()

knitr::kable(trade[1:5, 1:6])
```

## 参考リンク

- [Rで日本の統計データを効率的に取得しよう（e-Stat
  APIとjpstatパッケージで）](https://uchidamizuki.quarto.pub/blog/posts/2022/12/call-e-stat-api-in-r.html)
- [Rで人口ピラミッドのアニメーションを作る](https://uchidamizuki.quarto.pub/blog/posts/2023/01/create-an-animation-of-a-population-pyramid-in-r.html)
