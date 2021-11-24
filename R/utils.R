# global variables
japanstat_global <- new.env(parent = emptyenv())

# global variables for 'e-Stat'
japanstat_global$estat_url <- "http://api.e-stat.go.jp/"
japanstat_global$estat_path <- "rest/3.0/app/json/"
japanstat_global$estat_limit_downloads <- 1e5
japanstat_global$estat_limit_items <- 1e2
japanstat_global$estat_lang <- "J"

cat_subtle <- function(...) {
  cat(pillar::style_subtle(stringr::str_c(...)))
}

str_pad_common <- function(x) {
  stringr::str_pad(x,
                   width = max(stringi::stri_width(x)))
}

compact_query <- function(x) {
  x <- purrr::compact(x)
  vctrs::vec_slice(x, vctrs::vec_unique_loc(names(x)))
}
