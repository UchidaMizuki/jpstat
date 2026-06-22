test_that("webland", {
  skip_on_cran()
  skip_if(Sys.getenv("REINFOLIB_API_KEY") == "",
          "`REINFOLIB_API_KEY` is not set.")
  library(dplyr)

  city <- webland_city()
  expect_s3_class(city, "webland_city")

  city <- city |>
    itemise(pref_code = "01") |>
    collect()
  expect_s3_class(city, "tbl_df")

  trade <- webland_trade()
  expect_s3_class(trade, "webland_trade")

  trade <- trade |>
    itemise(year = "2015",
            quarter = "1",
            pref_code = "01",
            city_code = "01101") |>
    collect()
  expect_s3_class(trade, "tbl_df")
})
