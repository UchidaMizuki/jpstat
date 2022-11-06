test_that("webland", {
  library(dplyr)

  wl <- webland()
  expect_s3_class(wl, "webland_pref")
  expect_error(wl %>%
                 collect())

  wl <- wl %>%
    select(`沖縄県`) %>%
    collect()
  expect_s3_class(wl, "webland")

  wl %>%
    activate(city)
})
