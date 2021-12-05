# global variables
japanstat_global <- new.env(parent = emptyenv())

# global variables for e-Stat
japanstat_global$estat_url <- "http://api.e-stat.go.jp/"
japanstat_global$estat_path <- "rest/3.0/app/json/"
japanstat_global$estat_limit_downloads <- 1e5
japanstat_global$estat_limit_items <- 1e2

# global variables for RESAS
japanstat_global$resas_url <- "https://opendata.resas-portal.go.jp/"
japanstat_global$resas_path <- "api/v1/"

cat_subtle <- function(...) {
  cat(pillar::style_subtle(stringr::str_c(...)))
}

str_pad_common <- function(x, side = c("right", "left")) {
  side <- rlang::arg_match(side, c("right", "left"))

  if (vctrs::vec_is_empty(x)) {
    width <- 0L
  } else {
    width <- max(stringi::stri_width(x))
  }

  stringr::str_pad(x,
                   width = width,
                   side = side)
}

compact_query <- function(x) {
  x <- purrr::compact(x)
  vctrs::vec_slice(x, vctrs::vec_unique_loc(names(x)))
}

unnest_auto_deep <- function(data) {
  repeat {
    if (is.list(data[[ncol(data)]])) {
      data <- data %>%
        tidyr::unnest_auto(-1L)
    } else {
      break
    }
  }

  data
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
