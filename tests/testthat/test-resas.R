test_that("resas-power_for_industry", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  power_for_industry <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/industry/power/forIndustry.html")
  expect_s3_class(power_for_industry, "resas")

  power_for_industry <- power_for_industry |>
    itemise(year = "2012",
            pref_code = "1",
            city_code = "-",
            sic_code = "A")
  expect_s3_class(power_for_industry, "resas")

  power_for_industry <- collect(power_for_industry)

  expect_s3_class(power_for_industry, "tbl_df")
})

test_that("resas-population_change_rate", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  population_change_rate <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/population/sum/perYear.html")

  population_change_rate <- population_change_rate |>
    itemise(pref_code = "1") |>
    collect()

  expect_s3_class(population_change_rate$line, "tbl_df")
  expect_s3_class(population_change_rate$bar, "tbl_df")
})

test_that("resas-partner_docomo_destination", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  partner_docomo_destination <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/partner/docomo/destination.html") |>
    itemise(year = "2016",
            month = "01",
            period_of_day = "1",
            period_of_time = "4",
            gender = "1",
            age_range = "15",
            pref_code_destination = "13",
            city_code_destination = "13101",
            pref_code_residence = "13",
            city_code_residence = "-") |>
    collect()

  expect_s3_class(partner_docomo_destination, "tbl_df")
})

test_that("resas-population-society-for_age_class", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  population_society_for_age_class <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/population/society/forAgeClass.html") |>
    itemise(pref_code = "01") |>
    collect()

  expect_s3_class(population_society_for_age_class$`data/positive_age_classes`, "tbl_df")
  expect_s3_class(population_society_for_age_class$`data/negative_age_classes`, "tbl_df")
})

test_that("agriculture_crops_farmers_age_structure", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  agriculture_crops_farmers_age_structure <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/agriculture/crops/farmersAgeStructure.html") |>
    itemise(city_code = "11362",
            farmers_type = "1",
            gender_type = "3",
            matter = "3",
            pref_code = "11") |>
    collect()

  expect_s3_class(agriculture_crops_farmers_age_structure$`years/legend`, "tbl_df")
  expect_s3_class(agriculture_crops_farmers_age_structure$`years/data`, "tbl_df")
})

test_that("agriculture_crops_farmers_average_age", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  agriculture_crops_farmers_average_age <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/agriculture/crops/farmersAverageAge.html") |>
    itemise(city_code = "11362",
            farmers_type = "1",
            gender_type = "3",
            matter = "3",
            pref_code = "11") |>
    collect()

  expect_s3_class(agriculture_crops_farmers_average_age, "tbl_df")
})

test_that("prefectures", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  prefectures <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/prefectures.html")

  expect_s3_class(prefectures, "tbl_df")
})

test_that("medical_welfare_care_analysis_chart", {
  skip_on_cran()
  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  medical_welfare_care_analysis_chart <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/medicalWelfare/careAnalysis/chart.html",
                                               query = list(matter_1 = "1")) |>
    itemise(year = "2015",
            disp_type = "1",
            sort_type = "1",
            # matter_1 = "1",
            matter_2 = "101",
            broad_category_cd = "1",
            middle_category_cd = "100",
            pref_code = "2",
            city_code = "-",
            insurance_code = "-") |>
    collect()

  expect_s3_class(medical_welfare_care_analysis_chart, "tbl_df")
})
