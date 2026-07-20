# Summarize the table information of an 'e-Stat' table

[`summary()`](https://rdrr.io/r/base/summary.html) returns the
table-level metadata (title, survey date, publisher, and so on) of an
`estat` object created by
[`estat()`](https://uchidamizuki.github.io/jpstat/reference/estat.md).

## Usage

``` r
# S3 method for class 'estat'
summary(object, ...)

# S3 method for class 'tbl_estat'
summary(object, ...)
```

## Arguments

- object:

  An `estat` or `tbl_estat` object.

- ...:

  Ignored.

## Value

A `tibble` of table information.
