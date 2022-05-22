test_that("resas-power_for_industry", {
  skip_on_cran()

  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  power_for_industry <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/industry/power/forIndustry.html")
  expect_s3_class(power_for_industry, "resas")

  power_for_industry <- power_for_industry %>%
    activate(param) %>%
    itemise(year = 2012,
            pref_code = 1,
            city_code = "-",
            sic_code = "A") %>%

    activate(resp) %>%
    select(!c(data_employee,
              # misspelling: labar -> labor
              data_labar))
  expect_s3_class(power_for_industry, "resas_resp")

  power_for_industry <- collect(power_for_industry)

  expect_s3_class(power_for_industry, "tbl_df")
})

test_that("resas-partner_docomo_destination", {
  skip_on_cran()

  library(dplyr)

  X_API_KEY <- keyring::key_get("resas-api")
  partner_docomo_destination <- resas(X_API_KEY, "https://opendata.resas-portal.go.jp/docs/api/v1/partner/docomo/destination.html")

  partner_docomo_destination <- partner_docomo_destination %>%
    activate(param) %>%
    itemise(year = "2016",
            month = "01",
            period_of_day = "1",
            period_of_time = "4",
            gender = "1",
            age_range = "15",
            pref_code_destination = "13",
            city_code_destination = "13101",
            pref_code_residence = "13",
            city_code_residence = "-")

  partner_docomo_destination <- collect(partner_docomo_destination)

  expect_s3_class(partner_docomo_destination, "tbl_df")
})
