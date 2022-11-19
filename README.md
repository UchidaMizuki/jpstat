
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jpstat

<!-- badges: start -->
<!-- badges: end -->

**README is currently only available in Japanese.**

jpstatは日本政府統計のポータルサイトであるe-Statや RESAS
(地域経済分析システム) などのAPIを利用するためのツールを提供します．

現在，以下のAPIに対応しています．

- e-Stat API: <https://www.e-stat.go.jp/api/>
- RESAS API: <https://opendata.resas-portal.go.jp>
- 不動産取引価格情報取得API:
  <https://www.land.mlit.go.jp/webland/api.html>

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
詳細な使用方法は次の項目で説明します．

    # メタ情報の取得
    census <- estat(appId = "Your appId", 
                    statsDataId = "https://www.e-stat.go.jp/dbview?sid=0003410379")
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

## RESAS API

RESAS APIの利用にはアカウント登録 (X-API-KEYと呼ばれるAPIキーの発行)
が必要です
(詳しくは[ホームページ](https://opendata.resas-portal.go.jp)を参照してください)．
RESAS
APIの利用にあたっては，[API詳細仕様](https://opendata.resas-portal.go.jp/docs/api/v1/detail/index.html)を事前に確認してください．

    power_for_industry <- resas(X_API_KEY = "Your X-API-KEY", 
                                "https://opendata.resas-portal.go.jp/docs/api/v1/industry/power/forIndustry.html")
    power_for_industry

    #> # ✖ year:      年度            :  (Required)
    #> # ✖ pref_code: 都道府県コード  :  (Required)
    #> # ✖ city_code: 市区町村コード  :  (Required)
    #> # ✖ sic_code:  産業大分類コード:  (Required)
    #> # 
    #> # Please `itemise()`.

``` r
power_for_industry <- power_for_industry |>
  itemise(year = "2012",
          pref_code = "1",
          city_code = "-",
          sic_code = "A") |>
  collect()

knitr::kable(power_for_industry)
```

| pref_name | pref_code | sic_code | sic_name   | data/simc_code | data/simc_name | data/value | data/employee | data/labor |
|:----------|----------:|:---------|:-----------|:---------------|:---------------|-----------:|--------------:|-----------:|
| 北海道    |         1 | A        | 農業，林業 | 01             | 農業           |     4.4697 |        3.2743 |     0.9858 |
| 北海道    |         1 | A        | 農業，林業 | 02             | 林業           |     6.1208 |        3.0613 |     1.4438 |

## 不動産取引価格情報取得API

``` r
trade <- webland_trade()
trade
#> # ✖ from:      取引時期From  : 
#> # ✖ to:        取引時期To    : 
#> # ✖ pref_code: 都道府県コード: 
#> # ✖ city_code: 市区町村コード: 
#> # 
#> # Please `itemise()`.
```

``` r
trade <- trade |> 
  itemise(from = "20201",
          to = "20201",
          pref_code = "01",
          city_code = "01101") |> 
  collect()

knitr::kable(head(trade))
```

| type             | city_code | pref_name | city_name    | district_name | trade_price | floor_plan | area | building_year | structure | purpose | city_planning | coverage_ratio | floor_area_ratio | period           | renovation | region | land_shape | frontage | total_floor_area | use    | direction | classification | breadth | price_per_unit | unit_price | remarks |
|:-----------------|:----------|:----------|:-------------|:--------------|:------------|:-----------|:-----|:--------------|:----------|:--------|:--------------|:---------------|:-----------------|:-----------------|:-----------|:-------|:-----------|:---------|:-----------------|:-------|:----------|:---------------|:--------|:---------------|:-----------|:--------|
| 中古マンション等 | 01101     | 北海道    | 札幌市中央区 | 大通西        | 32000000    | ２ＬＤＫ   | 55   | 平成28年      | ＲＣ      | 住宅    | 商業地域      | 80             | 600              | 2020年第１四半期 | 未改装     | NA     | NA         | NA       | NA               | NA     | NA        | NA             | NA      | NA             | NA         | NA      |
| 宅地(土地と建物) | 01101     | 北海道    | 札幌市中央区 | 大通西        | 380000000   | NA         | 360  | 昭和36年      | 木造      | 住宅    | 商業地域      | 80             | 400              | 2020年第１四半期 | NA         | 商業地 | 長方形     | 15.0     | 160              | その他 | 北        | 市道           | 27.0    | NA             | NA         | NA      |
| 中古マンション等 | 01101     | 北海道    | 札幌市中央区 | 大通西        | 10000000    | １ＬＤＫ   | 40   | 昭和52年      | ＳＲＣ    | 住宅    | 商業地域      | 80             | 400              | 2020年第１四半期 | 改装済     | NA     | NA         | NA       | NA               | NA     | NA        | NA             | NA      | NA             | NA         | NA      |
| 中古マンション等 | 01101     | 北海道    | 札幌市中央区 | 大通西        | 9000000     | １ＬＤＫ   | 45   | 平成3年       | ＳＲＣ    | 住宅    | 商業地域      | 80             | 400              | 2020年第１四半期 | 改装済     | NA     | NA         | NA       | NA               | NA     | NA        | NA             | NA      | NA             | NA         | NA      |
| 中古マンション等 | 01101     | 北海道    | 札幌市中央区 | 大通西        | 3000000     | １Ｒ       | 20   | 昭和52年      | ＳＲＣ    | その他  | 商業地域      | 80             | 400              | 2020年第１四半期 | NA         | NA     | NA         | NA       | NA               | NA     | NA        | NA             | NA      | NA             | NA         | NA      |
| 中古マンション等 | 01101     | 北海道    | 札幌市中央区 | 大通西        | 3000000     | １Ｋ       | 15   | 昭和60年      | ＳＲＣ    | 住宅    | 商業地域      | 80             | 400              | 2020年第１四半期 | 未改装     | NA     | NA         | NA       | NA               | NA     | NA        | NA             | NA      | NA             | NA         | NA      |
