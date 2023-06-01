test_that("webland", {
  skip_on_cran()
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
    itemise(from = "20151",
            to = "20151",
            pref_code = "01",
            city_code = "01101") |>
    collect()
  expect_s3_class(trade, "tbl_df")
})
