test_that("resas() is defunct", {
  # The 'RESAS' API was discontinued on 2025-03-24.
  expect_error(resas(path = "https://opendata.resas-portal.go.jp/docs/api/v1/prefectures.html"),
               class = "defunctError")
})
