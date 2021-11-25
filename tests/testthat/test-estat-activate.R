test_that("estat-activate-tab", {
  data <- estat_census_2020 %>%
    estat_activate("\u8868\u7ae0\u4e8b\u9805", "new_name")
  expect_equal(attr(data, "active_id"), "tab")
  expect_equal(vctrs::vec_slice(data$new_name, data$id == "tab"), "new_name")

  data <- estat_census_2020 %>%
    estat_activate_tab("new_name")
  expect_equal(attr(data, "active_id"), "tab")
  expect_equal(vctrs::vec_slice(data$new_name, data$id == "tab"), "new_name")

  data <- estat_census_2020 %>%
    estat_activate_cat(1)
  expect_equal(attr(data, "active_id"), "cat01")

  data <- estat_census_2020 %>%
    estat_activate_area()
  expect_equal(attr(data, "active_id"), "area")

  data <- estat_census_2020 %>%
    estat_activate_time()
  expect_equal(attr(data, "active_id"), "time")
})
