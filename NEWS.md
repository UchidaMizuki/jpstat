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
