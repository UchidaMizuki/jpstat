library(tidyverse)
library(polite)
library(rvest)

# resas_v1_docs -----------------------------------------------------------

url <- "https://opendata.resas-portal.go.jp"

session <- bow(str_glue("{url}/docs/api/v1/index.html"),
               user_agent = "jpstat (uchidamizuki@vivaldi.net)",
               delay = 1)

scrape_utf8 <- partial(scrape,
                       content = "text/html; charset=UTF-8")

path <- scrape_utf8(session) |>
  html_element("div.sidemenu") |>
  html_elements("a") |>
  html_attr("href") |>
  discard(~ {
    str_ends(.x, "index.html") |
      str_detect(.x, "codes/[^.]+\\.html")
  })

read_resas_v1_docs <- function(setup) {
  docs <- session |>
    nod(setup$path) |>
    scrape_utf8() |>
    html_element("body > div > article")

  title <- docs |>
    html_element("h1") |>
    html_text2()

  description <- docs |>
    html_element("section:nth-child(2) > p") |>
    html_text2()

  sections <- docs |>
    html_elements("section:nth-child(n+3)")

  parameters <- NULL
  responses <- NULL

  for (section in sections) {
    h1 <- section |>
      html_elements("h1") |>
      html_text()

    if (!vctrs::vec_is_empty(h1) && h1 == "parameters") {
      parameters <- section |>
        html_table()

      if (!vec_is_empty(parameters)) {
        parameters <- parameters |>
          dplyr::mutate(Description = .data$Description |>
                          stringr::str_extract("^[^\\n]+(?=$|\\n)") |>
                          stringr::str_remove("\\s+$"),
                        Required = .data$Required == "true") |>
          dplyr::rename_with(stringr::str_to_lower)
      }
    }
    if (!vctrs::vec_is_empty(h1) && h1 == "responses") {
      responses <- section |>
        html_table() |>
        dplyr::mutate(Description = .data$Description |>
                        stringr::str_extract("^[^\\n]+(?=$|\\n)") |>
                        stringr::str_remove("\\s+$")) |>
        dplyr::rename_with(stringr::str_to_lower)
    }
  }

  list(title = title,
       description = description,
       parameters = parameters,
       responses = responses)
}

resas_v1_docs <- tibble(path = path) |>
  rowwise() |>
  mutate(doc = list({
    inform(path)
    setup <- list(url = url,
                  path = path)
    read_resas_v1_docs(setup)
  })) |>
  ungroup() |>
  mutate(path = path |>
           str_remove("/docs/") |>
           str_remove("\\.html$"))

resas_v1_docs <- list(url = url,
                      docs = resas_v1_docs)

write_rds(resas_v1_docs,
          "data-raw/resas_v1_docs.rds")
