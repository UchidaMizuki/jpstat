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

compact_query <- function(...) {
  x <- rlang::list2(...) %>%
    purrr::compact()

  stopifnot(is_named(x))

  x[vctrs::vec_unique_loc(names(x))]
}

remove_class <- function(x, class) {
  class(x) <- setdiff(class(x), class)
  x
}

add_class <- function(x, class) {
  class(x) <- c(class, class(x))
  x
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
