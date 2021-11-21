test_that("estat-0003183561", {
  estat_set_key(keyring::key_get("estat-api"))

  worker_city_2015 <- estat("0003183561")

  worker_city_2015 <- worker_city_2015 %>%

    activate_tab() %>%
    filter(name == "15歳以上就業者数") %>%
    select() %>%

    activate_cat(1, "industry") %>%
    filter(str_detect(name, "^[A-Z]")) %>%
    select(name) %>%

    activate_cat(2) %>%
    filter(name == "総数（年齢）") %>%
    select() %>%

    activate_cat(3) %>%
    filter(name == "総数（男女別）") %>%
    select() %>%

    activate_area("city") %>%
    select(code, name, level) %>%

    activate_time() %>%
    select() %>%

    japanstat::download_data(value_name = "worker")


})

estat_set_key(keyring::key_get("estat-api"))
statsDataId <- "0003411172"
census <- estat(statsDataId = statsDataId)

estat_table_info(census)

census <- census %>%

  activate_tab() %>%
  filter(name == "人口") %>%
  select() %>%

  activate_cat(1, "region") %>%
  select(name) %>%
  filter(name != "全国") %>%

  activate_time("year") %>%
  select(name) %>%
  filter(name == "2015年")
#
# data <- download_data(census)





