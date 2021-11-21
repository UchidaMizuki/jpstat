test_that("estat-0003183561", {
  estat_set_key(keyring::key_get("estat-api"))

  worker_city_2015 <- estat("0003183561")
  expect_s3_class(worker_city_2015, "estat")

  worker_city_2015 <- worker_city_2015 %>%

    activate_tab() %>%
    filter(name == "15歳以上就業者数") %>%
    select() %>%

    activate_cat(1, "industry") %>%
    filter(stringr::str_detect(name, "^[AB]")) %>%
    select(name) %>%

    activate_cat(2) %>%
    filter(name == "総数（年齢）") %>%
    select() %>%

    activate_cat(3, "sex") %>%
    filter(name != "総数（男女別）") %>%
    select(name) %>%

    activate_area() %>%
    filter(name == "北海道") %>%
    select() %>%

    activate_time() %>%
    select() %>%

    japanstat::download_data(value_name = "worker")

  expect_s3_class(worker_city_2015, "tbl_df")
  expect_setequal(names(worker_city_2015), c("industry", "sex", "worker"))
  expect_equal(vctrs::vec_size(worker_city_2015), 4)
})
