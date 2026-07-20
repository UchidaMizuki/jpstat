# jpstat 0.5.0

* `collect()` methods for `estat` objects are now documented, including the previously undocumented `n`, `names_sep`, `query`, and `limit` arguments.
* `collect()` no longer reports the total number of records with `print()`; it now uses `cli::cli_inform()` so the message can be suppressed with `suppressMessages()`.
* `estat()` now uses HTTPS for the 'e-Stat' API endpoint.
* The deprecated `appId` argument to `estat()` has been removed. Use `Sys.setenv(ESTAT_API_KEY = )` instead.
* `estat()` and `collect()` now automatically retry 'e-Stat' API requests on transient network failures.
* Errors raised by `estat()` and `collect()` are now classed (e.g. `jpstat_error_estat_api`, `jpstat_error_estat_missing_key`) so they can be caught programmatically.
* `estat_table_info()` is now defunct. Use `summary()` instead.
* The 'RESAS' API was discontinued on 2025-03-24. `resas()` is now defunct and errors when called.
* `webland_trade()` and `webland_city()` have been removed. The "Land General Information System" API they used was discontinued, and its replacement, the Real Estate Information Library API, does not expose metadata for navigatr's menu interface, so jpstat now focuses solely on the 'e-Stat' API.

# jpstat 0.4.0

* API keys for e-Stat and RESAS are now referenced from environment variables.
  * `appId` argument to `estat()` is now deprecated.
  * `X_API_KEY` argument of `resas()` is now deprecated.

# jpstat 0.3.3

* Correct errors on CRAN Package Check Results

# jpstat 0.3.2

* Fix a bug caused by the update to dplyr 1.1.0.
* Use purrr 1.0.0 progress bar and remove dependency on progress.

# jpstat 0.3.1

* Fix a bug where `resas()` could not rectangle data (#6).

# jpstat 0.3.0

* Add `resas()` to use 'RESAS' API (https://opendata.resas-portal.go.jp).
* Add `webland()` to use information on real estate transaction prices API 
(https://www.land.mlit.go.jp/webland/api.html).
* Add `summary.estat()` and deprecate `estat_table_info()`.

# jpstat 0.2.1

* Bug fix for column selection.

# jpstat 0.2.0

* Change the package name from japanstat to jpstat.
* Add dependency on navigatr package and support for activate() and rekey() 
  functions.

# jpstat 0.1.1

* Fix Imports

# jpstat 0.1.0
