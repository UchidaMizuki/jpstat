#' Download 'e-Stat' data
#'
#' @param x A \code{estat} object.
#' @param value_name A column name of the value.
#' @param query A list of additional queries.
#'
#' @return A \code{tbl} of the downloaded data.
#'
#' @examples
#' \dontrun{
#' estat_download(estat_census_2020)
#' }
#' @importFrom rlang %||%
#' @export
estat_download <- function(x,
                           value_name = "value",
                           query = NULL) {
  query <- estat_create_query(x, query)

  total_number <- estat_total_number(query)

  limit_downloads <- as.integer(query$limit %||% japanstat_global$estat_limit_downloads)
  start_position <- seq(1, total_number, limit_downloads)
  pb <- progress::progress_bar$new(total = vctrs::vec_size(start_position))
  data <- purrr::map_dfr(start_position,
                         function(start_position) {
                           data <- estat_download_impl(query, start_position, limit_downloads)
                           pb$tick()
                           data
                         })

  value <- data$value

  items <- tibble::as_tibble(x[c("id", "items")])
  items <- tidyr::unnest(items, "items")

  vars <- tibble::as_tibble(x[c("id", "vars")])
  new_name <- tibble::as_tibble(x[c("id", "new_name")])

  data <- data[names(data) != "value"]
  data <- tibble::rowid_to_column(data,
                                  var = "rowid")
  data <- tidyr::pivot_longer(data, !"rowid",
                              names_to = "id",
                              values_to = "code")
  data <- dplyr::left_join(data, items,
                           by = c("id", "code"))
  data <- dplyr::group_nest(data, dplyr::across("id"),
                            .key = "data")
  data <- dplyr::left_join(tibble::as_tibble(x[c("id", "vars", "new_name")]), data,
                           by = "id")
  data <- purrr::pmap_dfc(list(data$data, data$vars, data$new_name),
                          function(data, vars, new_name) {
                            data <- dplyr::arrange(data, "rowid")
                            data <- data[vars]
                            if (rlang::is_scalar_character(vars)) {
                              names(data) <- new_name
                            } else if (!vctrs::vec_is_empty(vars)) {
                              names(data) <- stringr::str_c(new_name, names(data),
                                                            sep = "_")
                            }
                            data
                          })
  stopifnot(!value_name %in% names(data))

  data[value_name] <- value
  data
}

estat_create_query <- function(x, query) {
  id <- stringr::str_to_sentence(x$id)
  id <- stringr::str_c("cd", id)

  query_codes <- purrr::map2(x$items, x$size_items_total,
                             function(items, size_items_total) {
                               size_items <- vctrs::vec_size(items)

                               if (size_items == size_items_total) {
                                 NULL
                               } else {
                                 stopifnot(size_items <= japanstat_global$estat_limit_items)

                                 stringr::str_c(items$code,
                                                collapse = ",")
                               }
                             })
  names(query_codes) <- id

  query <- c(attr(x, "query"),
             query_codes,
             list(metaGetFlg = "N"),
             query)
  compact_query(query)
}

estat_total_number <- function(query) {
  total_number <- estat_get(path = "getStatsData",
                            query = c(query,
                                      list(cntGetFlg = "Y")))
  total_number <- total_number$GET_STATS_DATA
  estat_check_status(total_number)

  total_number <- total_number$STATISTICAL_DATA$RESULT_INF$TOTAL_NUMBER
  print(stringr::str_glue("The total number of data is {total_number}."))
  total_number
}

estat_download_impl <- function(query, start_position, limit_downloads) {
  stats_data <- estat_get(path = "getStatsData",
                          query = c(query,
                                    list(startPosition = format(start_position,
                                                                scientific = FALSE),
                                         limit = format(limit_downloads,
                                                        scientific = FALSE))))
  stats_data <- stats_data$GET_STATS_DATA
  estat_check_status(stats_data)

  stats_data <- dplyr::bind_rows(stats_data$STATISTICAL_DATA$DATA_INF$VALUE)
  names(stats_data) <- stringr::str_remove(names(stats_data), "^@")
  vctrs::vec_slice(names(stats_data), names(stats_data) == "$") <- "value"
  stats_data <- stats_data[names(stats_data) != "unit"]
  stats_data
}
