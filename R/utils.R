big_mark <- function(x) {
  mark <- if (identical(getOption("OutDec"), ",")) {
    "."
  } else {
    ","
  }

  formatC(x,
          big.mark = mark)
}

commas <- function(...) {
  stringr::str_c(...,
                 collapse = ", ")
}

commas0 <- function(...) {
  stringr::str_c(...,
                 collapse = ",")
}

compact_query <- function(...) {
  dots_list(...,
            .named = TRUE,
            .homonyms = "first") |>
    purrr::compact()
}

str_to_snakecase <- function(string) {
  string |>
    stringr::str_split("(?=[[:upper:]])") |>
    purrr::map_chr(function(string) {
      string |>
        stringr::str_to_lower() |>
        stringr::str_c(collapse = "_")
    }) |>
    stringr::str_remove("^_")
}

str_to_camelcase <- function(string) {
  string |>
    stringr::str_split("_") |>
    purrr::map_chr(\(x) {
      exec(stringr::str_c, x[[1L]], !!!stringr::str_to_sentence(x[-1L]),
           collapse = "")
    })
}

get_content <- function(url, headers = list(), path = list(), query = list()) {
  httr2::request(url) |>
    httr2::req_headers(!!!headers) |>
    httr2::req_url_path_append(path) |>
    httr2::req_url_query(!!!query) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}



# Pref and city codes -----------------------------------------------------

as_pref_code <- function(x) {
  x |>
    stringr::str_pad(2L,
                     pad = "0")
}

as_city_code <- function(x) {
  x |>
    stringr::str_pad(5L,
                     pad = "0")
}



# Progress bar ------------------------------------------------------------

format_downloading <- "downloading [:bar] :percent"
