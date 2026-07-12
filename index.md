# jpstat

*[日本語](https://uchidamizuki.github.io/jpstat/README.ja.md)*

jpstat provides tools for using the API of
[e-Stat](https://www.e-stat.go.jp/api/), the portal site for Japanese
government statistics.

**“This service uses API functions from e-Stat, however its contents are
not guaranteed by government.”**
（「このサービスは、政府統計総合窓口(e-Stat)のAPI機能を使用していますが、サービスの内容は国によって保証されたものではありません。」）

## Installation

``` r

install.packages("jpstat")
```

You can install the development version of jpstat from
[GitHub](https://github.com/) with:

``` r

# install.packages("devtools")
devtools::install_github("UchidaMizuki/jpstat")
```

``` r

library(jpstat)
library(tidyverse)
```

## e-Stat API

Using the e-Stat API requires account registration (to obtain an API key
called an appId); see the [homepage](https://www.e-stat.go.jp/api/) for
details. Use of the data is also subject to the [terms of
use](https://www.e-stat.go.jp/terms-of-use).

The typical workflow for retrieving and reshaping data looks like this.
Here, we retrieve the male/female population of Tokyo and Osaka for 2010
and 2015 from the [System of Social and Demographic
Statistics](https://www.e-stat.go.jp/en/dbview?sid=0000010101). For a
more detailed, step-by-step walkthrough, see the [Accessing the e-Stat
API](https://uchidamizuki.github.io/jpstat/articles/estat.html) article.

``` R
# Set the API key
Sys.setenv(ESTAT_API_KEY = "Your appId")

# Retrieve the metadata
ssds <- estat(statsDataId = "https://www.e-stat.go.jp/en/dbview?sid=0000010101")
ssds

#> # ☐ tab:   Observation Value           [1] <code, name, level>
#> # ☐ cat01: A Population and Households [594] <code, name, level, unit>
#> # ☐ area:  AREA                        [48] <code, name, level>
#> # ☐ time:  SURVEY YEAR                 [51] <code, name, level>
#> # 
#> # Please `activate()`.
```

``` r

# Retrieve the male/female population of Tokyo and Osaka for 2010 and 2015
population <- ssds |>

  activate(tab) |>
  filter(name == "Observation value") |>
  select() |>

  activate(cat01) |>
  rekey("sex") |>
  filter(str_detect(name, "Total population \\((Male|Female)\\)")) |>
  select(name, unit) |>

  activate(area) |>
  rekey("pref") |>
  filter(name %in% c("Tokyo-to", "Osaka-fu")) |>
  select(code, name) |>

  activate(time) |>
  rekey("year") |>
  filter(name %in% c("2010", "2015")) |>
  select(name) |>

  collect(n = "population")
#> The total number of data is 8.

knitr::kable(population)
```

| sex_name | sex_unit | pref_code | pref_name | year_name | population |
|:---|:---|:---|:---|:---|:---|
| A110101_Total population (Male) | person | 13000 | Tokyo-to | 2010 | 6512110 |
| A110101_Total population (Male) | person | 13000 | Tokyo-to | 2015 | 6666690 |
| A110101_Total population (Male) | person | 27000 | Osaka-fu | 2010 | 4285566 |
| A110101_Total population (Male) | person | 27000 | Osaka-fu | 2015 | 4256049 |
| A110102_Total population (Female) | person | 13000 | Tokyo-to | 2010 | 6647278 |
| A110102_Total population (Female) | person | 13000 | Tokyo-to | 2015 | 6848581 |
| A110102_Total population (Female) | person | 27000 | Osaka-fu | 2010 | 4579679 |
| A110102_Total population (Female) | person | 27000 | Osaka-fu | 2015 | 4583420 |
