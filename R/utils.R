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
  paste0(...,
         collapse = ", ")
}

commas0 <- function(...) {
  paste0(...,
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

get_content <- function(url = NULL, config = list(), ..., handle = NULL) {
  out <- httr::GET(url = url,
                   config = config, ...,
                   handle = handle)
  httr::stop_for_status(out)
  httr::content(out)
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
