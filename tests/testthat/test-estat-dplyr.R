test_that("estat-filter", {
  expect_error(estat_census_2020 %>%
                 filter(name == "人口"))

  area <- estat_census_2020 %>%
    estat_activate_area()

  expect_error(area %>%
                 filter(name == "xxxxx"))

  area_00000 <- area %>%
    filter(code == "00000")
  items <- vctrs::vec_slice(area_00000$items, area_00000$id == "area")[[1L]]

  expect_equal(items$code, "00000")
})

test_that("estat-select", {
  expect_error(estat_census_2020 %>%
                 select(name))

  area <- estat_census_2020 %>%
    estat_activate_area()

  expect_error(area %>%
                 select(xxxxx))

  area_name <- area %>%
    select(code, name)
  vars <- vctrs::vec_slice(area_name$vars, area_name$id == "area")[[1L]]

  expect_equal(vars, c("code", "name"))
})

test_that("estat-select", {
  expect_error(estat_census_2020 %>%
                 slice(1))

  area <- estat_census_2020 %>%
    estat_activate_area()

  area_1to3 <- area %>%
    slice(1:3)
  items <- vctrs::vec_slice(area_1to3$items, area_1to3$id == "area")[[1L]]

  expect_equal(vctrs::vec_size(items), 3)
})
