# Changelog

## jpstat 0.5.0

- [`estat()`](https://uchidamizuki.github.io/jpstat/reference/estat.md)
  now uses HTTPS for the ‘e-Stat’ API endpoint.
- The ‘RESAS’ API was discontinued on 2025-03-24.
  [`resas()`](https://uchidamizuki.github.io/jpstat/reference/resas.md)
  is now defunct and errors when called.
- `webland_trade()` and `webland_city()` have been removed. The “Land
  General Information System” API they used was discontinued, and its
  replacement, the Real Estate Information Library API, does not expose
  metadata for navigatr’s menu interface, so jpstat now focuses solely
  on the ‘e-Stat’ API.

## jpstat 0.4.0

CRAN release: 2023-07-15

- API keys for e-Stat and RESAS are now referenced from environment
  variables.
  - `appId` argument to
    [`estat()`](https://uchidamizuki.github.io/jpstat/reference/estat.md)
    is now deprecated.
  - `X_API_KEY` argument of
    [`resas()`](https://uchidamizuki.github.io/jpstat/reference/resas.md)
    is now deprecated.

## jpstat 0.3.3

CRAN release: 2023-06-01

- Correct errors on CRAN Package Check Results

## jpstat 0.3.2

CRAN release: 2023-02-11

- Fix a bug caused by the update to dplyr 1.1.0.
- Use purrr 1.0.0 progress bar and remove dependency on progress.

## jpstat 0.3.1

CRAN release: 2022-12-25

- Fix a bug where
  [`resas()`](https://uchidamizuki.github.io/jpstat/reference/resas.md)
  could not rectangle data
  ([\#6](https://github.com/UchidaMizuki/jpstat/issues/6)).

## jpstat 0.3.0

CRAN release: 2022-11-21

- Add
  [`resas()`](https://uchidamizuki.github.io/jpstat/reference/resas.md)
  to use ‘RESAS’ API (<https://opendata.resas-portal.go.jp>).
- Add `webland()` to use information on real estate transaction prices
  API (<https://www.land.mlit.go.jp/webland/api.html>).
- Add `summary.estat()` and deprecate
  [`estat_table_info()`](https://uchidamizuki.github.io/jpstat/reference/estat_table_info.md).

## jpstat 0.2.1

CRAN release: 2022-05-10

- Bug fix for column selection.

## jpstat 0.2.0

CRAN release: 2022-02-24

- Change the package name from japanstat to jpstat.
- Add dependency on navigatr package and support for activate() and
  rekey() functions.

## jpstat 0.1.1

- Fix Imports

## jpstat 0.1.0
