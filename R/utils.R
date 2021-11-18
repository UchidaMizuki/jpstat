URL_ESTAT <- "http://api.e-stat.go.jp/"
URL_ESTAT_API <- "rest/3.0/app/json/"

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
