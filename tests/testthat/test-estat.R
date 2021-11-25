test_that("estat_0003411172", {
  skip_on_cran()

  estat_set_apikey(keyring::key_get("estat-api"))
  estat_set("limit_downloads", 1e1)

  census_2015 <- estat("https://www.e-stat.go.jp/dbview?sid=0003411172")
  expect_s3_class(census_2015, "estat")

  census_2015 <- census_2015 %>%
    estat_activate("\u8868\u7ae0\u9805\u76ee") %>%
    filter(name == "\u4eba\u53e3") %>%
    select() %>%

    estat_activate("\u5168\u56fd", "region") %>%
    select(code, name) %>%

    estat_activate("\u6642\u9593\u8ef8", "year") %>%
    select(name)

  census_2015 <- estat_download(census_2015, "pop")

  expect_s3_class(census_2015, "tbl_df")
  expect_setequal(names(census_2015), c("region_code", "region_name", "year", "pop"))
  expect_equal(vctrs::vec_size(census_2015), 78L)
})

test_that("estat_0003183561", {
  skip_on_cran()

  estat_set_apikey(keyring::key_get("estat-api"))

  worker_city_2015 <- estat("0003183561")
  expect_s3_class(worker_city_2015, "estat")

  worker_city_2015 <- worker_city_2015 %>%

    estat_activate("\u8868\u7ae0\u9805\u76ee") %>%
    filter(name == "15\u6b73\u4ee5\u4e0a\u5c31\u696d\u8005\u6570") %>%
    select() %>%

    estat_activate("\u7523\u696d\u5206\u985e", "industry") %>%
    filter(stringr::str_detect(name, "^[AB]")) %>%
    select(name) %>%

    estat_activate("\u5e74\u9f62") %>%
    filter(name == "\u7dcf\u6570\uff08\u5e74\u9f62\uff09") %>%
    select() %>%

    estat_activate("\u7537\u5973|\u6027\u5225", "sex") %>%
    filter(name != "\u7dcf\u6570\uff08\u7537\u5973\u5225\uff09") %>%
    select(name) %>%

    estat_activate("\u5f93\u696d\u5730") %>%
    filter(name == "\u5317\u6d77\u9053") %>%
    select() %>%

    estat_activate("\u5e74\u6b21") %>%
    select() %>%

    estat_download("worker")

  expect_s3_class(worker_city_2015, "tbl_df")
  expect_setequal(names(worker_city_2015), c("industry", "sex", "worker"))
  expect_equal(vctrs::vec_size(worker_city_2015), 4L)
})
