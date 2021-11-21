# global variables
japanstat_global <- new.env(parent = emptyenv())

# global variables for e-Stat
japanstat_global$estat_url <- "http://api.e-stat.go.jp/"
japanstat_global$estat_path <- "rest/3.0/app/json/"
japanstat_global$estat_limit_downloads <- 1e5
japanstat_global$estat_limit_items <- 1e2

cat_subtle <- function(...) {
  cat(pillar::style_subtle(stringr::str_c(...)))
}

str_pad_common <- function(x, side = c("right", "left")) {
  side <- rlang::arg_match(side, c("right", "left"))
  stringr::str_pad(x,
                   width = max(stringi::stri_width(x)),
                   side = side)
}

compact_query <- function(x) {
  x <- purrr::compact(x)
  vctrs::vec_slice(x, vctrs::vec_unique_loc(names(x)))
}

# e-Stat
estat_get <- function(path, query) {
  out <- httr::GET(japanstat_global$estat_url,
                   config = httr::add_headers(`Accept-Encoding` = "gzip"),
                   path = c(japanstat_global$estat_path, path),
                   query = query)
  httr::stop_for_status(out)
  httr::content(out)
}
estat_check_status <- function(x) {
  if (x$RESULT$STATUS != 0) {
    stop(x$RESULT$ERROR_MSG)
  }
}
