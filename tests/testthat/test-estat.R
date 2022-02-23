test_that("estat_census", {
  skip_on_cran()

  library(dplyr)

  estat_census <- estat(appId = keyring::key_get("estat-api"),
                        statsDataId = "https://www.e-stat.go.jp/dbview?sid=0003410379")
  expect_s3_class(estat_census, "estat")

  estat_census <- estat_census %>%

    activate(tab) %>%
    filter(code == "020") %>%
    select() %>%

    activate(cat01) %>%
    rekey("sex") %>%
    filter(code %in% c("110", "120")) %>%
    select(name) %>%

    activate(area) %>%
    filter(code %in% c("00100", "00200")) %>%
    select(code, name) %>%

    activate(time) %>%
    rekey("year") %>%
    filter(code %in% c("2010000000", "2015000000")) %>%
    select(name) %>%

    collect()

  expect_s3_class(estat_census, "tbl_df")
  expect_true(vec_size(estat_census) == 8)
})
