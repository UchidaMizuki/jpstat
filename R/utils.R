# global variables
japanstat_global <- new.env(parent = emptyenv())

# global variables for 'e-Stat'
japanstat_global$estat_url <- "http://api.e-stat.go.jp/"
japanstat_global$estat_path <- "rest/3.0/app/json/"
japanstat_global$estat_limit_collection <- 1e5
japanstat_global$estat_limit_items <- 1e2

# global variables for Information on real estate transaction-prices API
japanstat_global$iretp_url <- "https://www.land.mlit.go.jp/"

cat_subtle <- function(...) {
  cat(pillar::style_subtle(stringr::str_c(...)))
}

str_pad_common <- function(x) {
  stringr::str_pad(x,
                   width = max(stringi::stri_width(x)),
                   side = "right")
}

compact_query <- function(x) {
  x <- purrr::compact(x)
  vctrs::vec_slice(x, vctrs::vec_unique_loc(names(x)))
}

str_to_snakecase <- function(string) {
  string %>%
    stringr::str_split("(?=[[:upper:]])") %>%
    purrr::map_chr(function(string) {
      string %>%
        stringr::str_to_lower() %>%
        stringr::str_c(collapse = "_")
    }) %>%
    stringr::str_remove("^_")
}

as_pref_code <- function(x) {
  x %>%
    stringr::str_pad(2L,
                     pad = "0")
}

as_city_code <- function(x) {
  x %>%
    stringr::str_pad(5L,
                     pad = "0")
}
