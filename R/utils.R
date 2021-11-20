# global variables
japanstat_global <- new.env(parent = emptyenv())

japanstat_global$url_estat <- "http://api.e-stat.go.jp/"
japanstat_global$path_estat <- "rest/3.0/app/json/"

cat_subtle <- function(...) {
  cat(pillar::style_subtle(stringr::str_c(...)))
}

str_pad_common <- function(x, side = c("right", "left")) {
  side <- rlang::arg_match(side, c("right", "left"))
  stringr::str_pad(x,
                   width = max(stringi::stri_width(x)),
                   side = side)
}

# estat_key_names <- function(x) {
#   id <- str_pad_common(x$id)
#   name <- str_pad_common(x$name)
#   col <- purrr::map_chr(x$CLASS,
#                         function(CLASS) {
#                           stringr::str_c(names(CLASS),
#                                          collapse = ", ")
#                         })
#   col <- str_pad_common(col)
#
#   stringr::str_glue("{id}: {name} [{col}]")
# }

# estat_value_names <- function(x) {
#   code <- str_pad_common(x$code)
#   name <- str_pad_common(x$name)
#   unit <- str_pad_common(x$unit,
#                          side = "left")
#   level <- str_pad_common(x$level,
#                           side = "left")
#
#   dplyr::if_else(!is.na(level),
#                  stringr::str_glue("{code}: {name} [{unit}] (level: {level})"),
#                  stringr::str_glue("{code}: {name} [{unit}]"))
# }

# cat_tick <- function() {
#   cat(crayon::green(cli::symbol$tick))
# }

# flatten_query <- function(query) {
#   query <- purrr::compact(query)
#   nms <- unique(names(query))
#   query <- purrr::map(nms,
#                       function(nm) {
#                         query <- query[names(query) == nm]
#                         query <- purrr::modify(query, as.character)
#                         query <- purrr::flatten_chr(query)
#                         stringr::str_c(query,
#                                        collapse = ",")
#                       })
#   names(query) <- nms
#   query
# }
