
<!-- README.md is generated from README.Rmd. Please edit that file -->

# japanstat

<!-- badges: start -->
<!-- badges: end -->

**README is currently only available in Japanese.**

japanstatは日本政府統計のポータルサイトであるe-StatのAPIを利用するためのツールを提供します．
クエリの自動生成，データの収集，フォーマットなどの機能を備えています．

e-Stat APIの利用にはアカウント登録 (appIdと呼ばれるAPIキーの発行)
が必要です
(詳しくは[ホームページ](https://www.e-stat.go.jp/api/)を参照してください)．
また，データ利用に際しては[利用規約](https://www.e-stat.go.jp/terms-of-use)に従う必要があります．

**「このサービスは、政府統計総合窓口(e-Stat)のAPI機能を使用していますが、サービスの内容は国によって保証されたものではありません。」**

## インストール方法

``` r
install.packages("japanstat")
```

japanstatの開発版は，[GitHub](https://github.com/)から以下の方法でインストールできます．

``` r
# install.packages("devtools")
devtools::install_github("UchidaMizuki/japanstat")
```

## 使用方法

``` r
library(japanstat)
library(magrittr)
```

### データ取得・整形の概要

データ取得・整形の一連の流れは以下のようになります．詳細な使用方法は次の項目で説明します．

``` r
# APIキーの設定
estat_set_apikey("Your e-Stat appId")
```

``` r
# メタ情報の取得
census_2015 <- estat("https://www.e-stat.go.jp/dbview?sid=0003411172")

# 列名・アイテム数・属性変更
census_2015 <- census_2015 %>%
  
  estat_activate("表章項目") %>% 
  filter(name == "人口") %>% 
  select() %>% 
  
  estat_activate("全国", "region") %>% 
  select(code, name) %>% 
  
  estat_activate("時間軸", "year") %>% 
  filter(name %in% c("2000年", "2005年", "2010年", "2015年")) %>% 
  select(name)

# データのダウンロード
census_2015 <- estat_download(census_2015, "pop")
#> The total number of data is 12.

knitr::kable(census_2015)
```

| region_code | region_name | year   | pop       |
|:------------|:------------|:-------|:----------|
| 100         | 全国        | 2000年 | 126925843 |
| 100         | 全国        | 2005年 | 127767994 |
| 100         | 全国        | 2010年 | 128057352 |
| 100         | 全国        | 2015年 | 127094745 |
| 110         | 市部        | 2000年 | 99865289  |
| 110         | 市部        | 2005年 | 110264324 |
| 110         | 市部        | 2010年 | 116156631 |
| 110         | 市部        | 2015年 | 116137232 |
| 120         | 郡部        | 2000年 | 27060554  |
| 120         | 郡部        | 2005年 | 17503670  |
| 120         | 郡部        | 2010年 | 11900721  |
| 120         | 郡部        | 2015年 | 10957513  |

### データ取得・整形の流れ

japanstatでは，e-Stat APIのメタ情報取得 (getMetaInfo) と統計データ取得
(getStatsData) を用いて，統計表をダウンロードが可能です．
以下のように，APIキー (appId) をあらかじめ設定してください．

``` r
estat_set_apikey("Your e-Stat appId")
```

e-Statでは，統計表ごとに統計表ID (statsDataId)
が付与されています．統計表IDは， データセット情報ページ
([例1](https://www.e-stat.go.jp/stat-search/database?page=1&layout=datalist&toukei=00200521&tstat=000001080615&cycle=0&tclass1=000001124175&statdisp_id=0003411172&tclass2val=0))
や 統計表・グラフ表示ページ
([例2](https://www.e-stat.go.jp/dbview?sid=0003411172))
のURLからも取得することが可能です．

ここでは，[例2](https://www.e-stat.go.jp/dbview?sid=0003411172)に挙げた2015年国勢調査データを対象とします．
まず，データセット情報ページなどのURLまたは統計表ID (statsDataId)
を，`estat()`関数に入力してメタ情報 (統計データの属性情報)
を取得します．

``` r
# 2015年国勢調査 データセット情報ページ URL
census_2015 <- estat("https://www.e-stat.go.jp/dbview?sid=0003411172")
census_2015
#> # Keys
#> # [ ] tab  : 表章項目                     > tab   [2]  (code, name, level, unit)
#> # [ ] cat01: 全国，市部，郡部2015         > cat01 [3]  (code, name, level, parentCode)
#> # [ ] time : 時間軸（調査年組替表記有り） > time  [26] (code, name, level, parentCode)
#> #
#> # No active key
```

`estat_table_info()`関数で統計表情報を表示します．

``` r
knitr::kable(estat_table_info(census_2015))
```

| name                 | value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|:---------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| @id                  | 0003411172                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| STAT_NAME            | 00200521国勢調査                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GOV_ORG              | 00200総務省                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| STATISTICS_NAME      | 平成27年国勢調査 最終報告書「日本の人口・世帯」統計表                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| TITLE                | 1人口及び人口の割合－全国，全国市部・郡部（大正９年～平成27年）                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| CYCLE                | \-                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| SURVEY_DATE          | 201501-201512                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| OPEN_DATE            | 2020-05-22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| SMALL_AREA           | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| COLLECT_AREA         | 該当なし                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| MAIN_CATEGORY        | 02人口・世帯                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| SUB_CATEGORY         | 01人口                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| OVERALL_TOTAL_NUMBER | 130                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| UPDATED_DATE         | 2021-06-25                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| STATISTICS_NAME_SPEC | 平成27年国勢調査最終報告書「日本の人口・世帯」統計表                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| DESCRIPTION          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| TITLE_SPEC           | 人口及び人口の割合－全国，全国市部・郡部（大正９年～平成27年）1) 1945年は人口調査による。1945年及び1947年の沖縄県は調査されなかったため, 含まれていない｡2) 1960年の長野県西筑摩郡山口村と岐阜県中津川市の間の境界紛争地域の人口(73人)及び岡山県児島湾干拓第7区の人口(1,200人)は, 全国に含まれているが, 市部又は郡部には含まれていない｡3) 2010年（組替）は，2015年10月１日現在の市町村の境域に基づいて組み替えた2010年の人口を示す｡4) 2010年（組替）人口５万以上の市町村は，2015年10月１日現在の人口５万以上の市町村における2010年の人口を示す｡5) 2010年（組替）人口５万未満の市町村は，2015年10月１日現在の人口５万未満の市町村における2010年の人口を示す｡ |

当該データには，`tab`，`cat01`，`time`の3種類の列 (以下，キーと呼びます)
が存在します． それぞれのキーの (`>`の)
右側には以下の情報が記載されています．

1.  デフォルトでの列名 (`tab`など)
2.  アイテム数 (`[2]`など)
3.  コード・名称などの属性 (`(code, name, level, unit)`など)

ここからは，それぞれのキーごとに列名・アイテム数・属性を変更する方法を説明します．
それぞれのキーの情報を変更するためには，`estat_activate()`関数を用いてキーを選択します．
`estat_activate()`では，正規表現パターンでキーを選択します
(複数マッチする場合にはエラー)．
また，`estat_activate_tab()`関数など`id`でのキー選択も可能です．

例えば，以下のように`tab`キーをアクティブにします．

``` r
census_2015
#> # Keys
#> # [ ] tab  : 表章項目                     > tab   [2]  (code, name, level, unit)
#> # [ ] cat01: 全国，市部，郡部2015         > cat01 [3]  (code, name, level, parentCode)
#> # [ ] time : 時間軸（調査年組替表記有り） > time  [26] (code, name, level, parentCode)
#> #
#> # No active key

census_2015 %>% 
  # estat_activate_tab()
  estat_activate("表章項目")
#> # Keys
#> # [x] tab  : 表章項目                     > tab   [2]  (code, name, level, unit)
#> # [ ] cat01: 全国，市部，郡部2015         > cat01 [3]  (code, name, level, parentCode)
#> # [ ] time : 時間軸（調査年組替表記有り） > time  [26] (code, name, level, parentCode)
#> #
#> # A tibble: 2 x 4
#>   code  name             level unit 
#>   <chr> <chr>            <chr> <chr>
#> 1 020   人口             ""    人   
#> 2 1420  市部，郡部別割合 ""    ％
```

キーをアクティブにすると当該キーのアイテム情報が表示されます．
さらに，`filter()`関数や`select()`関数を用いてアイテム情報の絞り込みなどが可能です．
ここでは，「人口」のみを選択します．

``` r
census_2015 <- census_2015 %>% 
  estat_activate("表章項目") %>% 
  filter(name == "人口") %>% 
  # アイテム数が1つのみであるため列を全て削除
  select()
```

次に，`cat01`の「全国，市部，郡部2015」を選択します．`cat01`では，属性が分かりづらいため，`estat_activate()`関数
(ここでは，`"region"`) で名称の変更を行います．
また，上と同様に属性の絞り込みを行います．
ここでは，`code`と`name`列を選択します．この場合，ダウンロードデータの列名は，それぞれ，`region_code`，`region_name`になります．

``` r
census_2015 <- census_2015 %>% 
  # estat_activate_cat(1, "region") %>% 
  estat_activate("全国", "region") %>% 
  select(code, name)
```

上と同様に，`time`の「時間軸（調査年組替表記有り）」の名称変更・属性絞り込みを行います．
ここでは，2000～2015年データを選択します．

``` r
census_2015 <- census_2015 %>% 
  estat_activate("時間軸", "year") %>% 
  filter(name %in% c("2000年", "2005年", "2010年", "2015年")) %>% 
  select(name)
```

以上の操作により，以下のように列名・アイテム数・属性が変更できました．

``` r
census_2015
#> # Keys
#> # [ ] tab  : 表章項目                     > tab    [1] ()
#> # [ ] cat01: 全国，市部，郡部2015         > region [3] (code, name)
#> # [x] time : 時間軸（調査年組替表記有り） > year   [4] (name)
#> #
#> # A tibble: 4 x 1
#>   name  
#>   <chr> 
#> 1 2000年
#> 2 2005年
#> 3 2010年
#> 4 2015年
```

最後に，`estat_download()`関数を用いてデータをダウンロードします．

``` r
census_2015 <- census_2015 %>%
  # 値の名称を"pop"とする
  estat_download("pop")
#> The total number of data is 12.
knitr::kable(census_2015)
```

| region_code | region_name | year   | pop       |
|:------------|:------------|:-------|:----------|
| 100         | 全国        | 2000年 | 126925843 |
| 100         | 全国        | 2005年 | 127767994 |
| 100         | 全国        | 2010年 | 128057352 |
| 100         | 全国        | 2015年 | 127094745 |
| 110         | 市部        | 2000年 | 99865289  |
| 110         | 市部        | 2005年 | 110264324 |
| 110         | 市部        | 2010年 | 116156631 |
| 110         | 市部        | 2015年 | 116137232 |
| 120         | 郡部        | 2000年 | 27060554  |
| 120         | 郡部        | 2005年 | 17503670  |
| 120         | 郡部        | 2010年 | 11900721  |
| 120         | 郡部        | 2015年 | 10957513  |
