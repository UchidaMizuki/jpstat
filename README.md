
<!-- README.md is generated from README.Rmd. Please edit that file -->

# japanstat

<!-- badges: start -->
<!-- badges: end -->

README is currently only available in Japanese.

japanstatは日本政府統計のポータルサイトであるe-StatのAPIを利用するためのツールを提供します．
クエリの自動生成、データの収集、フォーマットなどの機能を備えています．

e-Stat APIの利用にはアカウント登録 (appIdと呼ばれるAPIキーの発行)
が必要です
(詳しくは[ホームページ](https://www.e-stat.go.jp/api/)を参照してください)．
また，データ利用に際しては[利用規約](https://www.e-stat.go.jp/terms-of-use)に従う必要があります．

**「このサービスは、政府統計総合窓口(e-Stat)のAPI機能を使用していますが、サービスの内容は国によって保証されたものではありません。」**

## インストール方法

japanstatの開発版が，[GitHub](https://github.com/)から以下の方法でインストールできます。

``` r
# install.packages("devtools")
devtools::install_github("UchidaMizuki/japanstat")
```

## 使用方法

``` r
library(japanstat)
library(magrittr)
```

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

当該データには，`tab`，`cat01`，`time`の3種類の列 (以下，キーと呼びます)
が存在することがわかります．
それぞれのキーの`>`の右側には以下の情報が記載されています
(括弧内は1行目の該当箇所)．

1.  デフォルトでの列名 (`tab`)
2.  アイテム数 (`[2]`)
3.  コード・名称などの属性 (`(code, name, level, unit)`)

ここからは，それぞれのキーごとに列名・アイテム数・属性を変更する方法を説明します．
それぞれのキーの情報を変更するためには，`estat_activate()`関数を用いてキーを選択します．

例えば，以下のように`tab`キーをアクティブにします．

``` r
# estat_activate(): 正規表現のパターンでキーを選択
census_2015 %>% 
  estat_activate("表章項目")
#> # Keys
#> # [x] tab  : 表章項目                     > tab   [2]  (code, name, level, unit)
#> # [ ] cat01: 全国，市部，郡部2015         > cat01 [3]  (code, name, level, parentCode)
#> # [ ] time : 時間軸（調査年組替表記有り） > time  [26] (code, name, level, parentCode)
#> #
#> # The tab items: 2 x 4
#>   code  name             level unit 
#>   <chr> <chr>            <chr> <chr>
#> 1 020   人口             ""    人   
#> 2 1420  市部，郡部別割合 ""    ％
# estat_activate_tab() でも選択可能
```

キーをアクティブにすると当該キーのアイテム情報が表示されます．
さらに，`filter()`関数や`select()`関数を用いてアイテム情報の絞り込みなどが可能です．
ここでは，「人口」のみを選択します．

``` r
census_2015 <- census_2015 %>% 
  estat_activate("表章項目") %>% 
  filter(name == "人口") %>% 
  # アイテム数が1行のみのため列を全て削除しても問題なし
  select()
```

次に，`cat01`の「全国，市部，郡部2015」を選択します．`cat01`では，属性が分かりづらいため，`estat_activate()`関数の第2引数
(ここでは，`"region"`) で名称の変更を行います．
また，上と同様に属性の絞り込みを行います．

``` r
census_2015 <- census_2015 %>% 
  estat_activate("全国", "region") %>% 
  # estat_activate_cat(1, "region") %>% 
  select(name)
```

上と同様に，`time`の「時間軸（調査年組替表記有り）」の名称変更・属性絞り込みを行います．

``` r
census_2015 <- census_2015 %>% 
  estat_activate("時間軸", "year") %>% 
  filter(name %in% c("2005年", "2010年", "2015年")) %>% 
  select(name)
```

最後に，`estat_download()`関数を用いてデータをダウンロードします．

``` r
census_2015 <- census_2015 %>%
  # 値の名称を"pop"とする
  estat_download("pop")
#> The total number of data is 9.
census_2015
#> # A tibble: 9 x 3
#>   region year   pop      
#>   <chr>  <chr>  <chr>    
#> 1 全国   2005年 127767994
#> 2 全国   2010年 128057352
#> 3 全国   2015年 127094745
#> 4 市部   2005年 110264324
#> 5 市部   2010年 116156631
#> 6 市部   2015年 116137232
#> 7 郡部   2005年 17503670 
#> 8 郡部   2010年 11900721 
#> 9 郡部   2015年 10957513
```

## まとめ

以上の操作をまとめて実行すると以下のようになります．

``` r
census_2015 <- estat("https://www.e-stat.go.jp/dbview?sid=0003411172")

census_2015 <- census_2015 %>%
  
  estat_activate("表章項目") %>% 
  filter(name == "人口") %>% 
  select() %>% 
  
  estat_activate("全国", "region") %>% 
  select(name) %>% 
  
  estat_activate("時間軸", "year") %>% 
  filter(name %in% c("2005年", "2010年", "2015年")) %>% 
  select(name)

census_2015 <- estat_download(census_2015, "pop")
#> The total number of data is 9.

census_2015
#> # A tibble: 9 x 3
#>   region year   pop      
#>   <chr>  <chr>  <chr>    
#> 1 全国   2005年 127767994
#> 2 全国   2010年 128057352
#> 3 全国   2015年 127094745
#> 4 市部   2005年 110264324
#> 5 市部   2010年 116156631
#> 6 市部   2015年 116137232
#> 7 郡部   2005年 17503670 
#> 8 郡部   2010年 11900721 
#> 9 郡部   2015年 10957513
```
