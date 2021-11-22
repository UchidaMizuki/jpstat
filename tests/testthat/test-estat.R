test_that("estat_worker_city_2015", {
  estat_set_apikey(keyring::key_get("estat-api"))

  worker_city_2015 <- estat("0003183561")
  expect_s3_class(worker_city_2015, "estat")

  worker_city_2015 <- worker_city_2015 %>%

    estat_activate("表章項目") %>%
    filter(name == "15歳以上就業者数") %>%
    select() %>%

    estat_activate("産業分類", "industry") %>%
    filter(stringr::str_detect(name, "^[AB]")) %>%
    select(name) %>%

    estat_activate("年齢") %>%
    filter(name == "総数（年齢）") %>%
    select() %>%

    estat_activate("男女|性別", "sex") %>%
    filter(name != "総数（男女別）") %>%
    select(name) %>%

    estat_activate("従業地") %>%
    filter(name == "北海道") %>%
    select() %>%

    estat_activate("年次") %>%
    select() %>%

    estat_download("worker")

  expect_s3_class(worker_city_2015, "tbl_df")
  expect_setequal(names(worker_city_2015), c("industry", "sex", "worker"))
  expect_equal(vctrs::vec_size(worker_city_2015), 4)
})
