test_that("estat-collect", {
  skip_on_cran()

  attr(estat_census_2020, "query")$appId <- keyring::key_get("estat-api")

  data <- estat_census_2020 %>%

    estat_activate_area() %>%
    slice(1:1e2) %>%

    estat_collect()

  expect_s3_class(data, "tbl_df")
  expect_equal(vctrs::vec_size(data), 300)
})
