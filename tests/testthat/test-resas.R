"population/composition/perYear"

resas_set_apikey(keyring::key_get("resas-api"))

resas_get_parameter("population/sum/perYear") -> res

res %>%
  rvest::html_elements("article > section") %>%
  purrr::map(function(x) {
    h1 <- rvest::html_element(x, "h1")
    h1 <- rvest::html_text(h1)



    table <- x %>%
      rvest::html_element("table")

    if (!is.na(table)) {
      rvest::html_table(table)
    }
  })

resas_get("cities", NULL) -> res
res$result %>%
  dplyr::bind_rows()
