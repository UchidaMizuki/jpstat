
<!-- README.md is generated from README.Rmd. Please edit that file -->

# e-Stat APIへのアクセス方法

``` r
library(jpstat)
library(dplyr)
```

jpstatでは，e-Stat APIのメタ情報取得 (getMetaInfo) と統計データ取得
(getStatsData) を用いて，統計表をダウンロードが可能です．

e-Statでは，統計表ごとに統計表ID (statsDataId)
が付与されています．統計表IDは， データセット情報ページ
([例1](https://www.e-stat.go.jp/stat-search/database?page=1&layout=datalist&toukei=00200521&tstat=000001011777&cycle=0&tclass1=000001011778&statdisp_id=0003410379&tclass2val=0))
や 統計表・グラフ表示ページ
([例2](https://www.e-stat.go.jp/dbview?sid=0003413949))
のURLからも取得することが可能です．

ここでは，[例2](https://www.e-stat.go.jp/dbview?sid=0003413949)に挙げた国勢調査データを対象として，
2010・2015年の東京都・大阪府における男女別人口を取得します．

まず，`estat()`関数に，appIdとデータセット情報ページなどのURLまたは統計表ID
(statsDataId) を入力してメタ情報 (統計データの属性情報) を取得します．

    # 国勢調査 データセット情報ページ URL
    census <- estat(appId = "Your e-Stat appId", 
                    statsDataId = "https://www.e-stat.go.jp/dbview?sid=0003413949")
    census

    #> # ☐ tab:   表章項目           [2] <code, name, level, unit>
    #> # ☐ cat01: 男，女及び総数2015 [3] <code, name, level>
    #> # ☐ area:  地域2015           [48] <code, name, level, parentCode>
    #> # ☐ time:  時間軸（調査年）   [21] <code, name, level>
    #> # 
    #> # Please `activate()`.

当該データには，`tab`，`cat01`，`area`, `time`の4種類の列
(以下，キーと呼びます) が存在します．
それぞれのキーには以下の情報が記載されています．

1.  デフォルトでの列名 (`tab`など)
2.  アイテム数 (`[2]`など)
3.  コード・名称などの属性 (`<code, name, level, unit>`など)

ここからは，それぞれのキーごとに列名・アイテム数・属性を変更する方法を説明します．
それぞれのキーの情報を変更するためには，`activate()`関数を用いてキーを選択します．

例えば，以下のように`tab`キーをアクティブにします．

``` r
census |> 
  activate(tab)
#> # ☒ tab:   表章項目           [2] <code, name, level, unit>
#> # ☐ cat01: 男，女及び総数2015 [3] <code, name, level>
#> # ☐ area:  地域2015           [48] <code, name, level, parentCode>
#> # ☐ time:  時間軸（調査年）   [21] <code, name, level>
#> # 
#> # A tibble: 2 × 4
#>   code  name     level unit           
#>   <chr> <chr>    <chr> <chr>          
#> 1 020   人口     ""    人             
#> 2 1120  人口性比 ""    女100人につき男

# Or
census |> 
  activate(1)
#> # ☒ tab:   表章項目           [2] <code, name, level, unit>
#> # ☐ cat01: 男，女及び総数2015 [3] <code, name, level>
#> # ☐ area:  地域2015           [48] <code, name, level, parentCode>
#> # ☐ time:  時間軸（調査年）   [21] <code, name, level>
#> # 
#> # A tibble: 2 × 4
#>   code  name     level unit           
#>   <chr> <chr>    <chr> <chr>          
#> 1 020   人口     ""    人             
#> 2 1120  人口性比 ""    女100人につき男
```

キーをアクティブにすると当該キーのアイテム情報が表示されます．
さらに，`filter()`関数や`select()`関数を用いてアイテム情報の絞り込みなどが可能です．
ここでは，「人口」のみを選択します．

``` r
census <- census |> 
  activate(tab) |> 
  filter(name == "人口") |> 
  # アイテム数が1つのみであるため列を全て削除
  select()
```

次に，`cat01`の「男，女及び総数2015」を選択します．`rekey()`関数によってキーの名称`cat01`を変更することが可能です（ここでは`sex`）．
キーの名称を変更することでデータダウンロード時の列名を指定ことができます．
また，上と同様に属性の絞り込みを行います．
ここでは，`name`列を選択します．

``` r
census <- census |> 
  activate(cat01) |>
  rekey("sex") |> 
  filter(name %in% c("男", "女")) |> 
  select(name)
```

上と同様に，`area`（「地域2015」）と`time`（「時間軸（調査年）」）の名称変更・属性絞り込みを行います．

``` r
census <- census |> 
  activate(area) |> 
  rekey("pref") |> 
  filter(name %in% c("東京都", "大阪府")) |> 
  select(code, name) |> 
  
  activate(time) |> 
  rekey("year") |> 
  filter(name %in% c("2010年", "2015年")) |> 
  select(name) 
```

以上の操作により，以下のように列名・アイテム数・属性が変更できました．

``` r
census
#> # ☐ tab:  表章項目           [1] <>
#> # ☐ sex:  男，女及び総数2015 [2] <name>
#> # ☐ pref: 地域2015           [2] <code, name>
#> # ☒ year: 時間軸（調査年）   [2] <name>
#> # 
#> # A tibble: 2 × 1
#>   name  
#>   <chr> 
#> 1 2010年
#> 2 2015年
```

最後に，`collect()`関数を用いてデータをダウンロードします．
`collect()`関数の`n`で値の名称を指定します．

``` r
census <- census |>
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
