# Collect data from an 'e-Stat' table

`collect()` downloads the statistical values selected from an `estat`
object with
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html),
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html),
and [`navigatr::rekey()`](https://rdrr.io/pkg/navigatr/man/rekey.html),
and returns them as a tidy `tibble`. Large tables are paginated
automatically.

## Usage

``` r
# S3 method for class 'estat'
collect(x, n = "n", names_sep = "_", query = list(), limit = 100000L, ...)

# S3 method for class 'tbl_estat'
collect(x, ...)
```

## Arguments

- x:

  An `estat` or `tbl_estat` object.

- n:

  Name of the column that holds the observed values.

- names_sep:

  Separator used to combine a classification's key (e.g. `"area"`) with
  its selected columns (e.g. `"name"`) into new column names (e.g.
  `"area_name"`).

- query:

  A list of additional queries passed to 'e-Stat's `getStatsData` API.

- limit:

  Maximum number of records requested per page. 'e-Stat' caps this at
  100000.

- ...:

  Ignored.

## Value

A `tibble`.

## Examples

``` r
if (FALSE) { # \dontrun{
Sys.setenv(ESTAT_API_KEY = "Your API key")
estat("https://www.e-stat.go.jp/dbview?sid=0003433219") |>
  dplyr::collect()
} # }
```
