test_that("estat_table_info() is defunct", {
  expect_error(
    estat_table_info(structure(list(), class = "estat")),
    class = "defunctError"
  )
})
