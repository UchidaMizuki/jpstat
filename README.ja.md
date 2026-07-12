# jpstat

[![CRAN
status](https://www.r-pkg.org/badges/version/jpstat)](https://CRAN.R-project.org/package=jpstat)
[![R-CMD-check](https://github.com/UchidaMizuki/jpstat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UchidaMizuki/jpstat/actions/workflows/R-CMD-check.yaml)

*[English](https://uchidamizuki.github.io/jpstat/README.md)*

jpstatは，日本政府統計のポータルサイトである
[e-Stat](https://www.e-stat.go.jp/api/)
のAPIを利用するためのツールを提供します．

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
library(tidyverse)
```

## e-Stat API

e-Stat APIの利用にはアカウント登録 (appIdと呼ばれるAPIキーの発行)
が必要です
(詳しくは[ホームページ](https://www.e-stat.go.jp/api/)を参照してください)．
また，データ利用に際しては[利用規約](https://www.e-stat.go.jp/terms-of-use)に従う必要があります．

データ取得・整形の一連の流れは以下のようになります．
ここでは，[社会・人口統計体系](https://www.e-stat.go.jp/dbview?sid=0000010101)を対象として，
2010・2015年の東京都・大阪府における男女別人口を取得します．

``` R
# APIキーの設定
Sys.setenv(ESTAT_API_KEY = "Your appId")

# メタ情報の取得
ssds <- estat(statsDataId = "https://www.e-stat.go.jp/dbview?sid=0000010101")
ssds

#> # ☐ tab:   観測値         [1] <code, name, level>
#> # ☐ cat01: Ａ　人口・世帯 [594] <code, name, level, unit>
#> # ☐ area:  地域           [48] <code, name, level>
#> # ☐ time:  調査年         [51] <code, name, level>
#> # 
#> # Please `activate()`.
```

``` r

# 2010・2015年の東京都・大阪府における男女別人口を取得
population <- ssds |>

  activate(tab) |>
  filter(name == "観測値") |>
  select() |>

  activate(cat01) |>
  rekey("sex") |>
  filter(str_detect(name, "総人口（[男女]）")) |>
  select(name, unit) |>

  activate(area) |>
  rekey("pref") |>
  filter(name %in% c("東京都", "大阪府")) |>
  select(code, name) |>

  activate(time) |>
  rekey("year") |>
  filter(name %in% c("2010年度", "2015年度")) |>
  select(name) |>

  collect(n = "population")
#> The total number of data is 8.

knitr::kable(population)
```

| sex_name             | sex_unit | pref_code | pref_name | year_name | population |
|:---------------------|:---------|:----------|:----------|:----------|:-----------|
| A110101_総人口（男） | 人       | 13000     | 東京都    | 2010年度  | 6512110    |
| A110101_総人口（男） | 人       | 13000     | 東京都    | 2015年度  | 6666690    |
| A110101_総人口（男） | 人       | 27000     | 大阪府    | 2010年度  | 4285566    |
| A110101_総人口（男） | 人       | 27000     | 大阪府    | 2015年度  | 4256049    |
| A110102_総人口（女） | 人       | 13000     | 東京都    | 2010年度  | 6647278    |
| A110102_総人口（女） | 人       | 13000     | 東京都    | 2015年度  | 6848581    |
| A110102_総人口（女） | 人       | 27000     | 大阪府    | 2010年度  | 4579679    |
| A110102_総人口（女） | 人       | 27000     | 大阪府    | 2015年度  | 4583420    |

## 参考リンク

- [Rで日本の統計データを効率的に取得しよう（e-Stat
  APIとjpstatパッケージで）](https://uchidamizuki.quarto.pub/blog/posts/2022/12/call-e-stat-api-in-r.html)
- [Rで人口ピラミッドのアニメーションを作る](https://uchidamizuki.quarto.pub/blog/posts/2023/01/create-an-animation-of-a-population-pyramid-in-r.html)
