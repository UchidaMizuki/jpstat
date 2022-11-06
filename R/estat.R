estat_stats_data_id <- function(statsDataId) {
  if (stringr::str_detect(statsDataId, "^\\d+$")) {
    statsDataId
  } else {
    # when statsDataId is url
    statsDataId <- statsDataId |>
      stringr::str_extract("(?<=\\?)[^\\?]+") |>
      stringr::str_split("&") |>
      dplyr::first() |>
      stringr::str_match("(.+)=(.+)")

    nms <- statsDataId[, 2L]
    statsDataId <- statsDataId[, 3L]
    names(statsDataId) <- nms

    statsDataId <- statsDataId[names(statsDataId) %in% c("statdisp_id", "sid")]
    dplyr::first(statsDataId)
  }
}

estat_get <- function(path, setup) {
  get_content(setup$url,
              config = httr::add_headers(`Accept-Encoding` = "gzip"),
              path = c(setup$path, path),
              query = setup$query)
}

#' Access 'e-Stat' data
#'
#' The `estat()` gets the meta-information of a statistical table by using `getMetaInfo` of the 'e-Stat' API,
#' and returns an `estat` object that allows editing of meta-information by `dplyr::filter()` and `dplyr::select()`.
#'
#' @param appId An 'appId' of 'e-Stat' API.
#' @param statsDataId A statistical data ID on 'e-Stat'.
#' @param lang A language, Japanese (`"J"`) or English (`"E"`).
#' @param query A list of additional queries.
#' @param path An e-Stat API path.
#'
#' @return A `estat` object.
#'
#' @examples
#' \dontrun{
#' estat("Your appId", "https://www.e-stat.go.jp/dbview?sid=0003433219")
#' }
#'
#' @seealso <https://www.e-stat.go.jp>
#' @seealso <https://www.e-stat.go.jp/en>
#'
#' @export
estat <- function(appId,
                  statsDataId,
                  lang = c("J", "E"),
                  query = list(),
                  path = "rest/3.0/app/json/") {
  statsDataId <- estat_stats_data_id(statsDataId)
  lang <- arg_match(lang, c("J", "E"))
  query <- compact_query(appId = appId,
                         statsDataId = statsDataId,
                         lang = lang,
                         !!!query)

  setup <- list(url = "http://api.e-stat.go.jp/",
                path = path,
                query = query)

  meta_info <- estat_get(path = "getMetaInfo",
                         setup = setup) |>
    purrr::chuck("GET_META_INFO") |>
    estat_check_status() |>
    purrr::chuck("METADATA_INF")

  table_info <- meta_info |>
    purrr::chuck("TABLE_INF") |>
    tibble::enframe() |>
    dplyr::mutate(value = .data$value |>
                    purrr::map_chr(~ {
                      .x |>
                        paste0(collapse = " ")
                    }))

  meta_info <- tibble::tibble(meta_info = meta_info |>
                                purrr::chuck("CLASS_INF", "CLASS_OBJ")) |>
    tidyr::unnest_wider("meta_info") |>
    dplyr::rename_with(~ {
      .x |>
        stringr::str_remove("^@")
    }) |>
    dplyr::rename(key = "id",
                  key_name = "name",
                  value = "CLASS") |>
    dplyr::mutate(value = .data$value |>
                    purrr::modify(~ {
                      .x |>
                        dplyr::bind_rows() |>
                        dplyr::rename_with(~ {
                          .x |>
                            stringr::str_remove("^@")
                        }) |>
                        tibble::rowid_to_column(".estat_rowid") |>
                        stickyr::new_sticky_tibble(cols = ".estat_rowid",
                                                   col_show = !".estat_rowid",
                                                   class = "tbl_estat")
                    }),
                  codes = .data$value |>
                    purrr::modify(~ .x$code),
                  width_key_name = .data$key_name |>
                    pillar::get_max_extent())

  navigatr::new_nav_menu(key = meta_info$key,
                         value = meta_info$value,
                         attrs = meta_info[c("key_name", "width_key_name")],

                         setup = setup,
                         query_name = meta_info$key,
                         codes = meta_info$codes,
                         table_info = table_info,

                         class = "estat")
}

estat_check_status <- function(x) {
  if (x$RESULT$STATUS != 0) {
    abort(x$RESULT$ERROR_MSG)
  }
  x
}

#' @export
summary.estat <- function(object, ...) {
  attr(object, "table_info")
}

#' @export
summary.tbl_estat <- function(object, ...) {
  object |>
    deactivate() |>
    summary()
}

#' @export
collect.estat <- function(x,
                          n = "n",
                          names_sep = "_",
                          query = list(),
                          limit = 1e5, ...) {
  setup <- attr(x, "setup")
  setup$query <- estat_query(x, query)

  total <- estat_total(setup)
  query_name <- attr(x, "query_name")

  if (total == 0) {
    data <- vec_recycle(list(character()),
                        vec_size(query_name) + 1L)
    names(data) <- c(query_name, n)
    data <- tibble::new_tibble(data)
  } else {
    start <- seq(1, total, limit)
    pb <- progress::progress_bar$new(format = format_downloading,
                                     total = vctrs::vec_size(start))
    data <- purrr::map_dfr(start,
                           function(start) {
                             out <- estat_collect(setup = setup,
                                                  start = start,
                                                  limit = limit,
                                                  n = n)
                             pb$tick()
                             out
                           })
  }

  cols <- list(x$key, x$value, query_name, attr(x, "codes")) |>
    purrr::pmap(function(key, value, query_name, codes) {
      value |>
        dplyr::rename_with(~ {
          paste(key, .x,
                sep = names_sep)
        },
        !".estat_rowid") |>
        dplyr::mutate(!!query_name := codes[.data$.estat_rowid],
                      .keep = "unused")
    })

  for (i in vec_seq_along(query_name)) {
    data <- data |>
      dplyr::left_join(cols[[i]],
                       by = query_name[[i]]) |>
      dplyr::select(!dplyr::all_of(query_name[[i]]))
  }

  data |>
    dplyr::relocate(!dplyr::all_of(n))
}

#' @export
collect.tbl_estat <- function(x, ...) {
  x |>
    deactivate() |>
    collect.estat(...)
}

estat_query <- function(x, query) {
  query_name <- x |>
    attr("query_name") |>
    stringr::str_to_sentence()
  query_name <- paste0("cd", query_name)

  query_codes <- purrr::map2(x$value, attr(x, "codes"),
                             function(value, codes) {
                               size <- vec_size(value)

                               if (size == vec_size(codes)) {
                                 NULL
                               } else {
                                 paste0(codes[value$.estat_rowid],
                                        collapse = ",")
                               }
                             })
  names(query_codes) <- query_name

  compact_query(!!!attr(x, "setup")$query,
                !!!query_codes,
                metaGetFlg = "N",
                !!!query)
}

estat_total <- function(setup) {
  setup$query <- c(setup$query,
                   list(cntGetFlg = "Y"))

  total <- estat_get(path = "getStatsData",
                     setup = setup) |>
    purrr::chuck("GET_STATS_DATA") |>
    estat_check_status() |>
    purrr::chuck("STATISTICAL_DATA", "RESULT_INF", "TOTAL_NUMBER")

  print(stringr::str_glue("The total number of data is {total}."))
  total
}

estat_collect <- function(setup, start, limit, n) {
  setup$query <- compact_query(!!!setup$query,
                               startPosition = format(start,
                                                      scientific = FALSE),
                               limit = format(limit,
                                              scientific = FALSE))
  estat_get(path = "getStatsData",
            setup = setup) |>
    purrr::chuck("GET_STATS_DATA") |>
    estat_check_status() |>
    purrr::chuck("STATISTICAL_DATA", "DATA_INF", "VALUE") |>
    dplyr::bind_rows() |>
    dplyr::rename_with(~ .x |>
                         stringr::str_remove("^@")) |>
    dplyr::rename(!!n := "$") |>
    dplyr::select(!dplyr::any_of("unit"))
}

# printing ----------------------------------------------------------------

#' @export
obj_sum.tbl_estat <- function(x) {
  attrs <- attributes(x)
  nms <- setdiff(names(x), ".estat_rowid")
  paste0(pillar::align(attrs$key_name, attrs$width_key_name), " ",
         "[", big_mark(vec_size(x)), "] ",
         "<", commas(nms), ">")
}
