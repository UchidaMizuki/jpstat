# Access 'e-Stat' data

The `estat()` gets the meta-information of a statistical table by using
`getMetaInfo` of the 'e-Stat' API, and returns an `estat` object that
allows editing of meta-information by
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
and
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html).

## Usage

``` r
estat(
  statsDataId,
  lang = c("J", "E"),
  query = list(),
  path = "rest/3.0/app/json"
)
```

## Arguments

- statsDataId:

  A statistical data ID on 'e-Stat'.

- lang:

  A language, Japanese (`"J"`) or English (`"E"`).

- query:

  A list of additional queries.

- path:

  An e-Stat API path.

## Value

A `estat` object.

## See also

<https://www.e-stat.go.jp>

<https://www.e-stat.go.jp/en>

## Examples

``` r
if (FALSE) { # \dontrun{
Sys.setenv(ESTAT_API_KEY = "Your API key")
estat("https://www.e-stat.go.jp/dbview?sid=0003433219")
} # }
```
